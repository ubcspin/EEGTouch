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
        
        %% Extract joystick data based on window around event timestamp
        [gs_events.w1abs, gs_events.w1var, gs_events.w1slp, gs_events.w1slp2] = ...
            extract_joystick(pfile.joystick, gs_events(:, 'timestamp_ms'), 1000, 5000);
        [gs_events.w2abs, gs_events.w2var, gs_events.w2slp, gs_events.w2slp2] = ...
            extract_joystick(pfile.joystick, gs_events(:, 'timestamp_ms'), 200, 5000);
        [gs_events.w3abs, gs_events.w3var, gs_events.w3slp, gs_events.w3slp2] = ...
            extract_joystick(pfile.joystick, gs_events(:, 'timestamp_ms'), 500, 5000);
        [gs_events.w4abs, gs_events.w4var, gs_events.w4slp, gs_events.w4slp2] = ...
            extract_joystick(pfile.joystick, gs_events(:, 'timestamp_ms'), 750, 5000);
        
        result = vertcat(result, gs_events);
    end
end

writetable(result, './experiments/results/event_joystick_asym.csv')
clearvars -except all_data result


%% CALCULATE SPREAD OF EVENT DATA MEASURE PER WINDOW SIZE
spread = table('Size', [0 5], 'VariableTypes', {'string', 'double', 'double', 'double', 'double'}, ... 
    'VariableNames', {'label', 'window_size', 'abs', 'var', 'slp'});

uniq_events = unique(result.label);
counts = cellfun(@(x) sum(ismember(result.label, x)), uniq_events, 'un', 0);
events_with_counts = cellstr(horzcat(uniq_events, counts));

fe = [""];
for i = 1:size(events_with_counts,1)
    count = str2num(events_with_counts{i,2});
    if count >= 16
        fe = vertcat(fe, [events_with_counts{i,1}]);
    end
end
fe = fe(2:end);

for i = 1:size(fe,1)
    ce = fe{i};
    ce_rows = result(find(strcmp(result.label, ce)), :);
    for j = 1:4
        current.label = ce;
        current.window_size = j;
        current.abs = var(ce_rows.(strcat('w', num2str(j), 'abs')));
        current.var = var(ce_rows.(strcat('w', num2str(j), 'var')));
        current.slp = var(ce_rows.(strcat('w', num2str(j), 'slp')));
        spread = vertcat(spread, struct2table(current));
    end
end

writetable(spread, './experiments/results/ej_spread_5500_9500.csv');


%% VISUALIZE DISTRIBUTION OF VALUES OF AN EVENT FOR A WINDOW SIZE (1000ms before, 5000ms after) 

% h = kstest(x) returns a test decision for the null hypothesis that the data in vector x 
% comes from a standard normal distribution, against the alternative that it does not come 
% from such a distribution, using the one-sample Kolmogorov-Smirnov test. The result h is 1 if 
% the test rejects the null hypothesis at the 5% significance level, or 0 otherwise.

d_res = {};
d_res{1,1} = 'label';
d_res{1,2} = 'spread-abs';
d_res{1,3} = 'spread-var';
d_res{1,4} = 'mean-abs';
d_res{1,5} = 'sd-abs';
d_res{1,6} = 'h-abs';
d_res{1,7} = 'p-abs';
d_res{1,8} = 'n-abs';
d_res{1,9} = 'kurt-abs';
d_res{1,10} = 'skew-abs';

d_res{1,11} = 'mean-var';
d_res{1,12} = 'sd-var';
d_res{1,13} = 'h-var';
d_res{1,14} = 'p-var';
d_res{1,15} = 'n-var';
d_res{1,16} = 'kurt-var';
d_res{1,17} = 'skew-var';


d_res{1,18} = 'iqr-abs';
d_res{1,19} = 'iqr-var';
d_res{1,20} = 'scene';

for i = 1:size(fe,1)
    ce = fe{i};
    ce_rows = result(find(strcmp(result.label, ce)), :);
    d_res{i+1,1} = ce; 
    
    % Kurtosis is a measure of how outlier-prone a distribution is. 
    % The kurtosis of the normal distribution is 3. Distributions that are 
    % more outlier-prone than the normal distribution have kurtosis greater 
    % than 3; distributions that are less outlier-prone have kurtosis less 
    % than 3.
    
    % Skewness is a measure of the asymmetry of the data around the sample mean. 
    % If skewness is negative, the data spreads out more to the left of the mean 
    % than to the right. If skewness is positive, the data spreads out more to 
    % the right. The skewness of the normal distribution (or any perfectly symmetric 
    % distribution) is zero.
    
    [h1, p1, w1] = swtest(ce_rows.w1abs, 0.05);
    d_res{i+1,4} = mean(ce_rows.w1abs);
    d_res{i+1,5} = std(ce_rows.w1abs);
    d_res{i+1,6} = h1;
    d_res{i+1,7} = p1;
    d_res{i+1,8} = size(ce_rows,1);
    d_res{i+1,9} = kurtosis(ce_rows.w1abs);
    d_res{i+1,10} = skewness(ce_rows.w1abs);
    
    [h2, p2, w2] = swtest(ce_rows.w1var, 0.05);
    d_res{i+1,11} = mean(ce_rows.w1var);
    d_res{i+1,12} = std(ce_rows.w1var);
    d_res{i+1,13} = h2;
    d_res{i+1,14} = p2;
    d_res{i+1,15} = size(ce_rows,1);
    d_res{i+1,16} = kurtosis(ce_rows.w1var);
    d_res{i+1,17} = skewness(ce_rows.w1var);
    
    % THIS IS WHERE I PUT IN MY OWN THRESHOLDS FOR SPREAD
    %  - change alpha to 0.10 for a more lax normality test. 
    %  - but I don't really believe the normality test works well for a
    %  histogram, because it seems like the values are mostly close
    %  together, and it still says there's a non-normal distribution
    %  (possibly because it's not as spread apart, but its all concentrated
    % near the same point. 
    %  - maybe it's one of those voting procedures; where you pick values
    %  that pass a couple of the tests. 
    
    % - Variance/standard deviation is a big deal for sure. Use that as a threshold first? 
    
    % SD Is the best measure of spread of an approximately normal
    % distribution.
    %   - but not if there are extreme values in a distribution, or when
    %   the distribution is skewed. Otherwise, IQR or semi IQR is preferred
    %   measures. 
    
    
    d_res{i+1,18} = iqr(ce_rows.w1abs);
    d_res{i+1,19} = iqr(ce_rows.w1var);
    
    % TODO: change this to something that takes into account both in some
    % way, but maybe have some kind of weighting? Or just have a simple
    % vote system. 
    if h1 == 0
        % fail to reject null hypothesis - abs dist is normal
        % use standard deviation if normal
        if d_res{i+1,5} <= 40
            d_res{i+1,2} = 'low';
            d_res{i+1,20} = string(mode(categorical(ce_rows.scene)));
        else 
            d_res{i+1,2} = 'high';
        end
    else
        % else, use IQR if non-normal 
        if d_res{i+1,18} <= 40
            d_res{i+1,2} = 'low';
            d_res{i+1,20} = string(mode(categorical(ce_rows.scene)));
        else 
            d_res{i+1,2} = 'high';
        end
    end
    
    if h2 == 0
        % fail to reject null hypothesis - var dist is normal
    else
        
    end
    
  
%     if h1 == 0
%         % fail to reject null hypothesis - abs dist is normal
%         % normal means that spread is low
%         d_res{i+1,2} = 'low';
%     else
%         % spread is high
%         d_res{i+1,2} = 'high';
%     end
%     
%     if h2 == 0
%         % fail to reject null hypothesis - var dist is normal
%         % normal means that spread is low
%         d_res{i+1,3} = 'low';
%     else
%         % spread is high
%         d_res{i+1,3} = 'high';
%     end
    
    if strcmp(ce, 'road-end')==1
        histfit(ce_rows.w1abs, 15, 'kernel');
    end
end

%% HELPER FUNCTIONS 

function events = clean_up_events(events) 
    events.label = strtrim(events.label);
    events.label = strrep(events.label, ' ', '-');
    events.label = lower(events.label);
end 

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
