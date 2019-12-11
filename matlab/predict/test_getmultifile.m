% loc = parent dir of processed dirs
loc = 'C:\Users\laura\Documents\SPIN\EEG_data';
subdir = 'processed';
%subdir = 'raw';
num_trials = 16; 
dirs = dir(fullfile(loc,subdir,'*'));
names = strings(length(dirs),1);
coll_tables = cell(num_trials,1);

j = 1;
for i = 3:length(dirs)
    if dirs(i).isdir
        names(j) = dirs(i).name;
        j = j+1;
    end
end
names(names == "") = [];
if ~exist('file_names','var')
    file_names = strings(length(names),1);
end
for i = 1:length(names) 
    if file_names(i) == ""
        proc_name = get_path_ui(fullfile(loc,subdir,names(i)), '*processed_data.mat', 'processed data file', 'Find the processed data file in this directory', true, false);
        file_names(i) = proc_name;
    else
        proc_name = file_names(i);
    end
    load(proc_name);
    [frequency_table, full_time_ms, f] = freq_table(processed_data, fullfile(loc,subdir,names(i)));
    coll_tables{str2num(processed_data.scalars.trial_number)}.freq_table = frequency_table;
    coll_tables{str2num(processed_data.scalars.trial_number)}.timestamp_ms = full_time_ms;
    coll_tables{str2num(processed_data.scalars.trial_number)}.f = f;
end

save(fullfile(loc,subdir, 'collected_tables.mat'),'coll_tables');

clearvars dirs f file_names frequency_table full_time_ms i j loc names num_trials proc_name processed_data subdir
%clearvars EEGSamplingRate Impedances_EEG_0 loc names dirs i eeg_name