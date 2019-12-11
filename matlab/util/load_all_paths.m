function all_paths = load_all_paths()
    % replace with parent directory of EEG data locally
    parent_directory = 'C:\Users\laura\Documents\SPIN\EEG_data';
    % replace with directory containing raw trial data
    num_trials = 16; 
    processed_data_directory = 'proc_data';
    trial_data_directory = 'raw';
    
    % add functions to path
    init_app;
    list_of_processed_directories = dir(fullfile(parent_directory,processed_data_directory,'*'));
    list_of_processed_directory_names = string({list_of_processed_directories.name})';
    logical_mask_is_directory = cell2mat({list_of_processed_directories.isdir})';
    list_of_processed_directory_names = list_of_processed_directory_names(logical_mask_is_directory);
    list_of_processed_directory_names(list_of_processed_directory_names == '.') = [];
    list_of_processed_directory_names(list_of_processed_directory_names == '..') = [];
    list_of_processed_directory_names(list_of_processed_directory_names == "") = [];
    
    list_of_trial_directories = dir(fullfile(parent_directory,trial_data_directory,'*'));
    list_of_trial_directory_names = string({list_of_trial_directories.name})';
    logical_mask_is_directory_t = cell2mat({list_of_trial_directories.isdir})';
    list_of_trial_directory_names = list_of_trial_directory_names(logical_mask_is_directory_t);
    list_of_trial_directory_names(list_of_trial_directory_names == '.') = [];
    list_of_trial_directory_names(list_of_trial_directory_names == '..') = [];
    list_of_trial_directory_names(list_of_trial_directory_names == "") = [];

    %trial_numbers = arrayfun(@(x) regexp(x,trialnum_regex,'match'),list_of_processed_directory_names,'UniformOutput',false);
    % the warning underlining the next line is wrong, ignore it
    %all_local_paths = cell(num_trials,1);
    
    all_paths = cell(num_trials,1);

    for i = 1:num_trials 
        all_paths{i}.processed_directory = fullfile(parent_directory, processed_data_directory, list_of_processed_directory_names(i));
        all_paths{i}.trial_directory = fullfile(parent_directory, trial_data_directory, list_of_trial_directory_names(i));
    end
end