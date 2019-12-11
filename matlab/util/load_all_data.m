function all_data = load_all_data()
    % replace with parent directory of EEG data locally
    parent_directory = 'C:\Users\Laura Cang\Documents\EEG';
    % replace with directory containing raw trial data
    num_trials = 16; 
    processed_data_directory = 'proc_data';
    
    % add functions to path
    init_app;
    list_of_processed_directories = dir(fullfile(parent_directory,processed_data_directory,'*'));

    list_of_processed_directory_names = string({list_of_processed_directories.name})';
    logical_mask_is_directory = cell2mat({list_of_processed_directories.isdir})';
    list_of_processed_directory_names = list_of_processed_directory_names(logical_mask_is_directory);
    list_of_processed_directory_names(list_of_processed_directory_names == '.') = [];
    list_of_processed_directory_names(list_of_processed_directory_names == '..') = [];
    list_of_processed_directory_names(list_of_processed_directory_names == "") = [];

    %trial_numbers = arrayfun(@(x) regexp(x,trialnum_regex,'match'),list_of_processed_directory_names,'UniformOutput',false);
    % the warning underlining the next line is wrong, ignore it
    %all_local_paths = cell(num_trials,1);
    all_data = cell(num_trials,1);

    for i = 1:length(list_of_processed_directory_names) 
        local_paths.trial_directory = '';
        local_paths.processed_directory = fullfile(parent_directory, processed_data_directory, list_of_processed_directory_names(i));
        % dummy data struct created just to pass trial number to processing
        %dummy_data.scalars.trial_number = char(trial_numbers{i});
        all_data{i} = load_trial_data(local_paths, struct);
    end

    %save(fullfile(parent_directory,'all_trials','all_data.mat'),'all_data');
end