load_all_processed;
tprocess_scenes;

resultVarTypes = {'double', 'double', 'string', 'string', 'double', 'double', 'double' ...
    'double', 'double', 'double', 'double', 'double', 'double'};
resultVarNames = {'pnum', 'timestamp_ms', 'emotion_words', 'calibrated_words', 'calibrated_values', 'w1abs', 'w1var', ...
    'w1slp', 'w1slp2', 'w2abs', 'w2var', 'w2slp', 'w2slp2'};
result = table('Size', [0 13], 'VariableTypes', resultVarTypes, ... 
    'VariableNames', resultVarNames);

for i = 1:size(all_data,1)
    pfile = all_data{i,1};
    
    if ~isempty(pfile)
        fprintf('Extracting interview {x} joystick data from participant %d...\n', i);
        
        interviews = pfile.calibrated_words;
        rows = size(interviews, 1);
        interviews.pnum = ones(rows, 1) * str2num(pfile.scalars.trial_number);
        
        %% normalize joystick to [-10 10] scale
        pfile.joystick.joystick = (pfile.joystick.joystick * 20 / max(pfile.joystick.joystick)) - 10;
        
        %% Extract joystick data based on window around event timestamp
        [interviews.w1abs, interviews.w1var, interviews.w1slp, interviews.w1slp2] = ...
            extract_joystick(pfile.joystick, interviews(:, 'timestamp_ms'), 1000, 1000);
        [interviews.w2abs, interviews.w2var, interviews.w2slp, interviews.w2slp2] = ...
            extract_joystick(pfile.joystick, interviews(:, 'timestamp_ms'), 2000, 2000);
        
        result = vertcat(result, interviews);
    end
end

writetable(result, './experiments/results/interview_joystick_asym.csv')
clearvars -except all_data result


% abs: max value of joystick data in time window
% variance: variance of joystick data in time window
% slp: end - start / time in a time window
% slp2: average of slopes of every 2 adjacent points in time window
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
