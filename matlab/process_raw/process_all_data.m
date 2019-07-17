function all_data = process_all_data()
    % replace with parent directory of EEG data locally
    parent_directory = 'C:\Users\laura\Documents\SPIN\EEG_data';
    % replace with directory containing raw trial data
    trials_directory = 'raw';
    num_trials = 16; 
    subdirectory_name_for_new_processed_data = 'proc_data';
    
    % add functions to path
    init_app;
    % regex to get trial number from raw directories
    trialnum_regex = '\d+$';
    list_of_raw_directories = dir(fullfile(parent_directory,trials_directory,'*'));

    list_of_raw_directory_names = string({list_of_raw_directories.name})';
    logical_mask_is_directory = cell2mat({list_of_raw_directories.isdir})';
    list_of_raw_directory_names = list_of_raw_directory_names(logical_mask_is_directory);
    list_of_raw_directory_names(list_of_raw_directory_names == '.') = [];
    list_of_raw_directory_names(list_of_raw_directory_names == '..') = [];
    list_of_raw_directory_names(list_of_raw_directory_names == "") = [];

    trial_numbers = arrayfun(@(x) regexp(x,trialnum_regex,'match'),list_of_raw_directory_names,'UniformOutput',false);
    % the warning underlining the next line is wrong, ignore it
    logical_mask_trial_numbers_is_empty = cellfun(@(x) length(x) == 0, trial_numbers);
    trial_numbers(logical_mask_trial_numbers_is_empty) = {"unknown"};

    processed_parent_directory = fullfile(parent_directory,subdirectory_name_for_new_processed_data);
    if ~exist(processed_parent_directory, 'dir')
        mkdir(processed_parent_directory);
    end
    all_local_paths = cell(num_trials,1);
    all_data = cell(num_trials,1);

    for i = 1:length(list_of_raw_directory_names) 
        all_local_paths{i}.trial_directory = fullfile(parent_directory, trials_directory, list_of_raw_directory_names(i));
        all_local_paths{i}.processed_directory = fullfile(processed_parent_directory, trial_numbers{i});
        if ~exist(all_local_paths{i}.processed_directory, 'dir')
            mkdir(all_local_paths{i}.processed_directory);
        end
        % dummy data struct created just to pass trial number to processing
        dummy_data = struct;
        dummy_data.scalars.trial_number = char(trial_numbers{i});
        all_data{i} = process_data(all_local_paths{i}, dummy_data);
    end

    save(fullfile(parent_directory,'all_trials','all_data.mat'),'all_data');
end