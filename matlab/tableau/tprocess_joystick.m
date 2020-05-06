load_all_processed;

joy = {};
for i = 1:size(all_data,1)
    pfile = all_data{i,1};
    
    if ~isempty(pfile)
        fprintf('Processing joystick data from participant %d...\n', i);
        
        joy{i,1} = i;
        joy{i,2} = size(pfile.joystick.joystick, 1);
        joy{i,3} = mean(pfile.joystick.joystick);
        joy{i,4} = std(pfile.joystick.joystick);
        joy{i,5} = min(pfile.joystick.joystick);
        
        q_joy = quantile(pfile.joystick.joystick, 3);
        joy{i,6} = q_joy(1,1);
        joy{i,7} = q_joy(1,2);
        joy{i,8} = q_joy(1,3);
        
        joy{i,9} = max(pfile.joystick.joystick);
        joy{i,10} = joy{i,8} - joy{i,6};
        joy{i,11} = pfile.joystick.timestamp_ms(joy{i,2}) - pfile.joystick.timestamp_ms(1);
    end
end

result = cell2table(joy, 'VariableNames', {'pnum', 'n', 'mean', 'std', 'min', 'q1', 'median', 'q3' ...
    'max', 'iqr', 'duration_ms'});
writetable(result, './tableau/joystick.csv')

clearvars -except all_data result