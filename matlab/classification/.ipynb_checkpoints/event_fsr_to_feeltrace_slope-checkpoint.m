if ~isfile('../experiments/results/event_joystick_asym.csv')
    event_joystick;
elif ~isfile('../experiments/results/event_fsr_asym.csv')
    event_fsr;
end

resultVarTypes = {'double', 'string', 'double', 'string', 'string', ...
    'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double'};
resultVarNames = {'timestamp_ms', 'label', 'pnum', 'type', 'scene', ...
    'key_hold', 'key_left', 'key_down', 'key_right', 'key_jump', 'feeltrace', 'feeltrace_slope', 'slope_bin', 'feeltrace_calibrated'};
result = table('Size', [0 14], 'VariableTypes', resultVarTypes, ... 
    'VariableNames', resultVarNames);
    

e_joystick = readtable('event_joystick_asym.csv');
e_fsr = readtable('event_fsr_asym.csv');

result = e_joystick(:, {'timestamp_ms', 'label', 'pnum', 'type', 'scene'});
result(:, {'key_hold', 'key_left', 'key_down', 'key_right', 'key_jump'}) = e_fsr(:, {'A0abs', 'A1abs', 'A2abs', 'A3abs', 'A4abs'});
result(:, {'feeltrace', 'feeltrace_slope', 'feeltrace_calibrated'}) = e_joystick(:, {'w1abs', 'w1slp', 'w5abs'});
result.feeltrace_10 = e_joystick.w4abs;
result.feeltrace_slope(isnan(result.feeltrace_slope)) = 0;
result.slope_zscore = zscore(result{:, {'feeltrace_slope'}});
result.slope_bin = arrayfun(@(x) x > 0, result{:, {'slope_zscore'}});
result.slope_tri = arrayfun(@categorize_val, result{:, {'slope_zscore'}});
result = [result e_fsr(:, 30:128)];

writetable(result, './train/event_fsr_to_feeltrace_train.csv');
