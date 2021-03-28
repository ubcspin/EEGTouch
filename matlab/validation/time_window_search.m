load_all_processed;

%{
resultVarTypes = {'double', 'double', 'string', 'string', 'double'};
resultVarNames = {'pnum', 'timestamp_ms', 'emotion_words', 'calibrated_words', 'calibrated_values'};
result = table('Size', [0 5], 'VariableTypes', resultVarTypes, ... 
    'VariableNames', resultVarNames);
%}

result = table();
time_window_x = 1:500:2001;
time_window_y = 2000:-500:0;
calibration = readtable('calibration.csv');
for i = 1:size(all_data,1)
    pfile = all_data{i,1};
    
    if ~isempty(pfile)
        fprintf('Extracting interview {x} joystick data from participant %d...\n', i);
        
        interviews = pfile.calibrated_words;
        rows = size(interviews, 1);
        interviews.pnum = ones(rows, 1) * str2num(pfile.scalars.trial_number);
        calibrated_words = calibration{calibration.Participant_ == str2double(pfile.scalars.trial_number), 2:29};
        
        %% normalize joystick to [-10 10] scale
        joystick_10 = pfile.joystick(:, :);
        calibrated_word_range = max(interviews.calibrated_values) - min(interviews.calibrated_values);
        joystick_10.joystick = (joystick_10.joystick * 20 / ...
                               (max(joystick_10.joystick) - min(joystick_10.joystick))) - 10;
                      
        %% linear interpolate joystick data
        new_time_stamp = 0:2:joystick_10{end, 'timestamp_ms'};
        joystick_10_interp = interp1(joystick_10.timestamp_ms, joystick_10.joystick, new_time_stamp);
        joystick_10 = table();
        joystick_10.timestamp_ms = transpose(new_time_stamp);
        joystick_10.joystick = transpose(joystick_10_interp);
        
        for i = 1:numel(time_window_x)
            for j = 1:numel(time_window_y)
                colname = genvarname(['w_' num2str(time_window_x(i)) '_' num2str(time_window_y(j))]);
                [interviews.(colname), a, b, c] = extract_joystick(joystick_10, interviews(:, 'timestamp_ms'), ...
                                                                   time_window_x(i), time_window_y(j));
            end
        end
        
        result = vertcat(result, interviews);
    end
end

writetable(result, 'interview_joystick.csv')
clearvars -except all_data result

