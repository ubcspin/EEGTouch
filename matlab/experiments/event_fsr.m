load_all_processed;
tprocess_scenes;

resultVarTypes = {'double', 'string', 'double', 'string', 'string', 'double', 'double' ...
    'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', ...
    'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', ...
    'double', 'double'};
resultVarNames = {'timestamp_ms', 'label', 'pnum', 'type', 'scene', 'A0abs', 'A0var', ...
    'A0slp', 'A0slp2', 'A1abs', 'A1var', 'A1slp', 'A1slp2', 'A2abs', 'A2var', 'A2slp', 'A2slp2', ...
    'A3abs', 'A3var', 'A3slp', 'A3slp2', 'A4abs', 'A4var', 'A4slp', 'A4slp2', 'maxabs', 'maxvar', ...
    'maxslp', 'maxslp2'};
result = table('Size', [0 29], 'VariableTypes', resultVarTypes, ... 
    'VariableNames', resultVarNames);

for i = 1:size(all_data,1)
    pfile = all_data{i,1};
    
    if ~isempty(pfile)
        fprintf('Extracting event {x} fsr data from participant %d...\n', i);
        
        %% Combine all game and sound event data together, sort by timestamp 
        g_rows = size(pfile.events.game_controlled_visual, 1);
        s_rows = size(pfile.events.game_controlled_sound, 1);
        
        pfile.events.game_controlled_visual.pnum = ones(g_rows, 1) * i;
        pfile.events.game_controlled_sound.pnum = ones(s_rows, 1) * i;
        pfile.events.game_controlled_visual.type = repmat({'game_controlled_visual'}, g_rows, 1);
        pfile.events.game_controlled_sound.type = repmat({'game_controlled_sound'}, s_rows, 1);
        
        % Label scene data for each event
        
        offset = 500; % offset in ms for labeling scene data (events at the edge of scenes)
        
        scenes_game = cell(size(pfile.events.game_controlled_visual,1),1);
        for j = 1:size(pfile.events.game_controlled_visual,1)
            ts = pfile.events.game_controlled_visual{j,1};
            rows = all_scenes.pnum == i & (all_scenes.start_ms - offset) <= ts & (all_scenes.end_ms + offset) >= ts;
            scene = all_scenes(rows, {'scene'});
            if size(scene,1) > 0
                scenes_game{j} = scene{1,1};
            else
                scenes_game{j} = 'none';
            end 
        end
        pfile.events.game_controlled_visual.scene = scenes_game;
        
        scenes_sound = cell(size(pfile.events.game_controlled_sound,1),1);
        for j = 1:size(pfile.events.game_controlled_sound,1)
            ts = pfile.events.game_controlled_sound{j,1};
            rows = all_scenes.pnum == i & (all_scenes.start_ms - offset) <= ts & (all_scenes.end_ms + offset) >= ts;
            scene = all_scenes(rows, {'scene'});
            scene_row = pfile.events.game_controlled_sound(j,:);
            if size(scene,1) > 0
                scenes_sound{j} = scene{1,1};
            else
                scenes_sound{j} = 'none';
            end 
        end
        pfile.events.game_controlled_sound.scene = scenes_sound;
        
        gs_events = vertcat(pfile.events.game_controlled_visual, pfile.events.game_controlled_sound);
        gs_events = sortrows(gs_events, [1,2]);
        gs_events = clean_up_events(gs_events);
        
        % resample, linearly interpolate and smooth fsr data
        Fs = 500;
        fsr_abs = max( ...
                [pfile.fsr.A0, ...
                 pfile.fsr.A1, ...
                 pfile.fsr.A2, ...
                 pfile.fsr.A3, ...
                 pfile.fsr.A4], [], 2);
        
                 
        new_timestamp_ms = 0:2:pfile.fsr.timestamp_ms(length(pfile.fsr.timestamp_ms));
        fsr_A0 = interp1(pfile.fsr.timestamp_ms, pfile.fsr.A0, new_timestamp_ms);
        fsr_A1 = interp1(pfile.fsr.timestamp_ms, pfile.fsr.A1, new_timestamp_ms);
        fsr_A2 = interp1(pfile.fsr.timestamp_ms, pfile.fsr.A2, new_timestamp_ms);
        fsr_A3 = interp1(pfile.fsr.timestamp_ms, pfile.fsr.A3, new_timestamp_ms);
        fsr_A4 = interp1(pfile.fsr.timestamp_ms, pfile.fsr.A4, new_timestamp_ms);
        fsr_max = interp1(pfile.fsr.timestamp_ms, fsr_abs, new_timestamp_ms);
        
        fsr_A0 = lowpass(fsr_A0, 0.1, Fs); % 0.1 is arbitrary based on inspection in plotting
        fsr_A1 = lowpass(fsr_A1, 0.1, Fs);
        fsr_A2 = lowpass(fsr_A2, 0.1, Fs);
        fsr_A3 = lowpass(fsr_A3, 0.1, Fs);
        fsr_A4 = lowpass(fsr_A4, 0.1, Fs);
        fsr_max = lowpass(fsr_max, 0.1, Fs);
        
        %% Extract fsr data based on window around event timestamp
        [gs_events.A0abs, gs_events.A0var, gs_events.A0slp, gs_events.A0slp2] = ...
            extract_fsr(array2table([new_timestamp_ms', fsr_A0'], 'VariableNames', {'timestamp_ms', 'fsr'}), ...
            gs_events(:, 'timestamp_ms'), 1000, 5000);
        [gs_events.A1abs, gs_events.A1var, gs_events.A1slp, gs_events.A1slp2] = ...
            extract_fsr(array2table([new_timestamp_ms', fsr_A1'], 'VariableNames', {'timestamp_ms', 'fsr'}), ...
            gs_events(:, 'timestamp_ms'), 1000, 5000);
        [gs_events.A2abs, gs_events.A2var, gs_events.A2slp, gs_events.A2slp2] = ...
            extract_fsr(array2table([new_timestamp_ms', fsr_A2'], 'VariableNames', {'timestamp_ms', 'fsr'}), ...
            gs_events(:, 'timestamp_ms'), 1000, 5000);
        [gs_events.A3abs, gs_events.A3var, gs_events.A3slp, gs_events.A3slp2] = ...
            extract_fsr(array2table([new_timestamp_ms', fsr_A3'], 'VariableNames', {'timestamp_ms', 'fsr'}), ...
            gs_events(:, 'timestamp_ms'), 1000, 5000);
        [gs_events.A4abs, gs_events.A4var, gs_events.A4slp, gs_events.A4slp2] = ...
            extract_fsr(array2table([new_timestamp_ms', fsr_A4'], 'VariableNames', {'timestamp_ms', 'fsr'}), ...
            gs_events(:, 'timestamp_ms'), 1000, 5000);
        [gs_events.maxabs, gs_events.maxvar, gs_events.maxslp, gs_events.maxslp2] = ...
            extract_fsr(array2table([new_timestamp_ms', fsr_max'], 'VariableNames', {'timestamp_ms', 'fsr'}), ...
            gs_events(:, 'timestamp_ms'), 1000, 5000);
        
        gs_events.Var3 = [];
        gs_events = gs_events(~ismissing(gs_events.label), :);
        
        result = vertcat(result, gs_events);
    end
end

%% populate max key
to_compute = result{:, {'A0abs', 'A1abs', 'A2abs', 'A3abs', 'A4abs'}};
[m, result.maxkey] = max(to_compute, [], 2);
result.maxkey = result.maxkey - 1;

%% clean up event-scene misalignment
uniq_events = unique(result.label);
for i = 3:size(uniq_events)
    event_label = uniq_events{i};
    scene_rows = result(result.label == event_label, {'scene'});
    uniq_scenes = unique(scene_rows.scene);
    correct_scene = 'none';
    if length(uniq_scenes) > 2
        if strcmp(event_label, 'truck-start-2')
            correct_scene = 'Fridge';
        elseif strcmp(event_label, 'resurface') | strcmp(event_label, 'lights-water')
            correct_scene = 'Water';
        elseif strcmp(event_label, 'sharp-breath-2')
            correct_scene = 'Road';
        end
    elseif length(uniq_scenes) <= 2
        if strcmp(event_label, 'bank-land') | strcmp(event_label, 'crate-bark') | strcmp(event_label, 'fall-land-crate')
            correct_scene = 'Crate';
        elseif strcmp(event_label, 'black-death-water') | strcmp(event_label, 'lights-track') ...
            | strcmp(event_label, 'water-dart') | strcmp(event_label, 'water-shot-sound')
            correct_scene = 'Water';
        elseif strcmp(event_label, 'dog-nonjump') | strcmp(event_label, 'dog-turns')
            correct_scene = 'River';
        elseif strcmp(event_label, 'loud-steps') | strcmp(event_label, 'road-end') | strcmp(event_label, 'tree-road-2')
            correct_scene = 'Road';
        elseif strcmp(event_label, 'dogs-loud')
            correct_scene = 'Dogs';
        elseif strcmp(event_label, 'ground-die')
            correct_scene = 'River';
        elseif strcmp(event_label, 'fall-land-start')
            correct_scene = 'none';
        elseif strcmp(event_label, 'wet-steps-end') | strcmp(event_label, 'wet-steps-start')
            correct_scene = 'Pond';
        else
            correct_scene = uniq_scenes(uniq_scenes ~= 'none');
        end
    end
    if strcmp(event_label, 'experimenter-in') | strcmp(event_label, 'experimenter-out')
        correct_scene = 'none'
    end
    result(result.label == event_label, {'scene'}) = {correct_scene};
end

writetable(result, './experiments/results/event_fsr_asym.csv')
clearvars -except all_data result

%% filter event based on spread of fsr intensity in all channels
eventVarTypes = {'string', 'double', 'double', 'double', 'double', 'double', 'double'};
eventVarNames = {'label', 'A0', 'A1', 'A2', 'A3', 'A4', 'max'};
event_aggregated = table('Size', [0 7], 'VariableTypes', eventVarTypes, ... 
    'VariableNames', eventVarNames);
uniq_events = unique(result.label);
for i = 3:size(uniq_events)
    event_label = uniq_events{i};
    event_rows = result(result.label == event_label, {'A0abs', 'A1abs', 'A2abs', 'A3abs', 'A4abs', 'maxabs'});
    event_avg = mean(event_rows{:, :}, 1);
    event_var = iqr(event_rows{:, :}, 1);
    hi_f_lo_s = (event_avg > 700) & (event_var < 200);
    hi_s = (event_var > 700) * 2;
    md_f_lo_s = (event_avg < 700) & (event_avg > 300) & (event_var < 200) * 3;
    event_r = hi_f_lo_s + hi_s + md_f_lo_s;
    event_row = {event_label, event_r(1), event_r(2), event_r(3), event_r(4), event_r(5), event_r(6)};
    event_aggregated = [event_aggregated; event_row];
end

writetable(event_aggregated, './experiments/results/event_fsr_spread.csv');

%% Extract fsr data with high intensity and low spread
resultVarTypes = {'double', 'string', 'double', 'string', 'string', 'double', 'double' ...
    'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', ...
    'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', ...
    'double', 'double', 'double'};
resultVarNames = {'timestamp_ms', 'label', 'pnum', 'type', 'scene', 'A0abs', 'A0var', ...
    'A0slp', 'A0slp2', 'A1abs', 'A1var', 'A1slp', 'A1slp2', 'A2abs', 'A2var', 'A2slp', 'A2slp2', ...
    'A3abs', 'A3var', 'A3slp', 'A3slp2', 'A4abs', 'A4var', 'A4slp', 'A4slp2', 'maxabs', 'maxvar', ...
    'maxslp', 'maxslp2', 'maxkey'};
hi_f_lo_s = table('Size', [0 30], 'VariableTypes', resultVarTypes, ... 
    'VariableNames', resultVarNames);
    
for i = 3:size(uniq_events)
    event_label = uniq_events{i};
    filter = event_aggregated(i-2, :);
    event_rows = result(result.label == event_label, :);
    if filter.A0 ~= 1
        event_rows.A0abs = zeros(height(event_rows), 1);
    end
    if filter.A1 ~= 1
        event_rows.A1abs = zeros(height(event_rows), 1);
    end
    if filter.A2 ~= 1
        event_rows.A2abs = zeros(height(event_rows), 1);
    end
    if filter.A3 ~= 1
        event_rows.A3abs = zeros(height(event_rows), 1);
    end
    if filter.A4 ~= 1
        event_rows.A4abs = zeros(height(event_rows), 1);
    end
    if filter.max ~= 1
        event_rows.maxabs = zeros(height(event_rows), 1);
    end
    hi_f_lo_s = [hi_f_lo_s; event_rows];
end
writetable(hi_f_lo_s, './experiments/results/hi_f_lo_s.csv')


function events = clean_up_events(events) 
    events.label = strtrim(events.label);
    events.label = strrep(events.label, ' ', '-');
    events.label = lower(events.label);
end 

function [abs, variance, slp, slp2] = extract_fsr(timeseries, timestamps, low_off, high_off) 
    abs = zeros(height(timestamps), 1);
    variance = zeros(height(timestamps), 1);
    slp = zeros(height(timestamps), 1);
    slp2 = zeros(height(timestamps), 1);

    for j = 1:height(timestamps)
        ts = timestamps{j,1};
        rows = timeseries.timestamp_ms <= ts + high_off & ...
            timeseries.timestamp_ms >= ts - low_off;
        fsr_in_window = timeseries(rows, {'timestamp_ms', 'fsr'});
        if size(fsr_in_window, 1) > 0
            abs(j,1) = max(fsr_in_window.fsr);
            variance(j,1) = var(fsr_in_window.fsr);
            
            % Calculate average slope in window
            slp(j,1) = (fsr_in_window.fsr(end) - fsr_in_window.fsr(1)) ...
                / (fsr_in_window.timestamp_ms(end) - fsr_in_window.timestamp_ms(1));
            
            % Calculate individual slopes in window and average
            slopes = diff(fsr_in_window.fsr)./diff(fsr_in_window.timestamp_ms);
            slp2(j,1) = mean(slopes);
        else 
            abs(j,1) = NaN;
            variance(j,1) = NaN;
            slp(j,1) = NaN;
            slp2(j,1) = NaN;
        end 
    end 
    return;
end