%% LOAD ALL PROCESSED DATA

if  exist('all_data', 'var') == 1
    disp('Using pre-existing all_data variable.');
    return;
end 

disp('Could not find existing all_data variable. Loading from disk...');

ptotal = 23;
all_data = cell(23, 1);

for i = 1:ptotal
    str_i = sprintf('%02d',i);
    fprintf('Loading data from participant %d... ', i);
    try 
        pfile = load(strcat('processed_data_pxx/processed_data_p', str_i, '/processed_data.mat'));
        all_data{i,1} = rename_fields(pfile.processed_data);
        fprintf('SUCCESS!\n');
    catch ex
        fprintf('FAILED.\n');
    end 
end

clearvars str_i i ptotal pfile ex
