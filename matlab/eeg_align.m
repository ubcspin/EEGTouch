% If no trial directory variable, try current directory.
if ~exist('trial_directory', 'var')
    global trial_directory;
    trial_directory = get_path_ui(pwd, '', 'trial directory', 'This is the directory that contains one trial worth of raw data you downloaded from the server.', false);
end

% get matlab EEG file - find in directory or from UI dialog.
eeg_name = get_path_ui(trial_directory, '*201*.mat', 'EEG Matlab data', 'The file is usually named with a date and time stamp with the extension .mat and in the main trial directory.',true);

% load matlab EEG file
load(eeg_name);

% find name of eeg data variable
% (the file has the eeg data in a matrix with an auto-generated name)
% this find the data and puts it in a var called 'eeg_data'
varnames = who('*mff');
eeg_data_raw = eval(varnames{1});

% crop eeg data to din sync 
eeg_data = eeg_data_raw(:,(processed_data.scalars.din_time_ms-processed_data.scalars.eeg_start_time_ms)/1000:end).';

% add a row for millisecond timestamp to synced eeg data
stamps = ones(length(eeg_data),1);
stamps(1) = 0;
stamps = cumsum(stamps);
eeg_table = table(stamps,eeg_data,'VariableNames',{'timestamp_ms','eeg'});
processed_data.eeg = eeg_table;