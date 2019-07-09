load_all_processed;
tprocess_scenes;

resultVarTypes = {'double', 'string', 'double', 'string', 'string', 'double', 'double' ...
    'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double'};
resultVarNames = {'timestamp_ms', 'label', 'pnum', 'type', 'scene', 'w1abs', 'w1var', ...
    'w1slp', 'w1slp2', 'w2abs', 'w2var', 'w2slp', 'w2slp2', 'w3abs', 'w3var', 'w3slp', 'w3slp2', 'w4abs', 'w4var', 'w4slp', 'w4slp2' };
result = table('Size', [0 21], 'VariableTypes', resultVarTypes, ... 
    'VariableNames', resultVarNames);

for i = 1:size(all_data,1)
    pfile = all_data{i,1};
    
    if ~isempty(pfile)
        fprintf('Extracting event {x} joystick data from participant %d...\n', i);
        
        %% Combine all game and sound event data together, sort by timestamp 
        g_rows = size(pfile.processed_data.events.game, 1);
        s_rows = size(pfile.processed_data.events.sound, 1);
        
        pfile.processed_data.events.game.pnum = ones(g_rows, 1) * i;
        pfile.processed_data.events.sound.pnum = ones(s_rows, 1) * i;
        pfile.processed_data.events.game.type = repmat({'game'}, g_rows, 1);
        pfile.processed_data.events.sound.type = repmat({'sound'}, s_rows, 1);
        
        % Label scene data for each event
        
        offset = 500; % offset in ms for labeling scene data (events at the edge of scenes)
        
        scenes_game = cell(size(pfile.processed_data.events.game,1),1);
        for j = 1:size(pfile.processed_data.events.game,1)
            ts = pfile.processed_data.events.game{j,1};
            rows = all_scenes.pnum == i & (all_scenes.start_ms - offset) <= ts & (all_scenes.end_ms + offset) >= ts;
            scene = all_scenes(rows, {'scene'});
            if size(scene,1) > 0
                scenes_game{j} = scene{1,1};
            else
                scenes_game{j} = 'none';
            end 
        end
        pfile.processed_data.events.game.scene = scenes_game;
        
        scenes_sound = cell(size(pfile.processed_data.events.sound,1),1);
        for j = 1:size(pfile.processed_data.events.sound,1)
            ts = pfile.processed_data.events.sound{j,1};
            rows = all_scenes.pnum == i & (all_scenes.start_ms - offset) <= ts & (all_scenes.end_ms + offset) >= ts;
            scene = all_scenes(rows, {'scene'});
            scene_row = pfile.processed_data.events.sound(j,:);
            if size(scene,1) > 0
                scenes_sound{j} = scene{1,1};
            else
                scenes_sound{j} = 'none';
            end 
        end
        pfile.processed_data.events.sound.scene = scenes_sound;
        
        gs_events = vertcat(pfile.processed_data.events.game, pfile.processed_data.events.sound);
        gs_events = sortrows(gs_events, [1,2]);
        
        %% Extract joystick data based on window around event timestamp
        [gs_events.w1abs, gs_events.w1var, gs_events.w1slp, gs_events.w1slp2] = ...
            extract_joystick(pfile.processed_data.feeltrace, gs_events(:, 'timestamp_ms'), 3750, 3750);
        [gs_events.w2abs, gs_events.w2var, gs_events.w2slp, gs_events.w2slp2] = ...
            extract_joystick(pfile.processed_data.feeltrace, gs_events(:, 'timestamp_ms'), 7500, 7500);
        [gs_events.w3abs, gs_events.w3var, gs_events.w3slp, gs_events.w3slp2] = ...
            extract_joystick(pfile.processed_data.feeltrace, gs_events(:, 'timestamp_ms'), 10000, 10000);
        [gs_events.w4abs, gs_events.w4var, gs_events.w4slp, gs_events.w4slp2] = ...
            extract_joystick(pfile.processed_data.feeltrace, gs_events(:, 'timestamp_ms'), 3000, 12000);
        
        result = vertcat(result, gs_events);
    end
end

writetable(result, './experiments/results/event_joystick.csv')

function [abs, variance, slp, slp2] = extract_joystick(timeseries, timestamps, low_off, high_off) 
    abs = zeros(height(timestamps), 1);
    variance = zeros(height(timestamps), 1);
    slp = zeros(height(timestamps), 1);
    slp2 = zeros(height(timestamps), 1);

    for j = 1:height(timestamps)
        ts = timestamps{j,1};
        rows = timeseries.timestamp_ms <= ts + high_off & ...
            timeseries.timestamp_ms >= ts - low_off;
        joystick_in_window = timeseries(rows, {'timestamp_ms', 'joystick'});
        if size(joystick_in_window, 1) > 0
            abs(j,1) = max(joystick_in_window.joystick);
            variance(j,1) = var(joystick_in_window.joystick);
            
            % Calculate average slope in window
            slp(j,1) = (joystick_in_window.joystick(end) - joystick_in_window.joystick(1)) ...
                / (joystick_in_window.timestamp_ms(end) - joystick_in_window.timestamp_ms(1));
            
            % Calculate individual slopes in window and average
            slopes = diff(joystick_in_window.joystick)./diff(joystick_in_window.timestamp_ms);
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
