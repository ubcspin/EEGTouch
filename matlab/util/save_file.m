function is_save_successful = save_file(local_paths,trial_data)
    try
        save(fullfile(local_paths.processed_directory, ['trial_data' trial_data.scalars.trial_number '.mat']),'trial_data');
    catch ME
        is_save_successful = false;
        return;
    end
    is_save_successful = true;
end
    
