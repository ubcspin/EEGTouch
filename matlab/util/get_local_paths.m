function local_paths = get_local_paths()
%GET_LOCAL_PATHS

    local_paths = struct;
    
    trial_directory_type = 'trial directory';
    trial_directory_helpmessage = 'This is the directory that contains one trial worth of raw data you downloaded from the server.';
    local_paths.trial_directory = get_path_ui(pwd, '', trial_directory_type, trial_directory_helpmessage,false,false);
    
    processed_directory_type = 'processed data directory';
    processed_directory_helpmessage = 'This is the directory where processed data from this trial will be saved to.';
    local_paths.processed_directory = get_path_ui(local_paths.trial_directory, '', processed_directory_type, processed_directory_helpmessage,false, false);
    
    [fid, errormsg] = fopen(fullfile(local_paths.processed_directory,'not_a_real_file.txt'), 'a');
    errormsg_2 = fclose(fid);
    delete(fullfile(local_paths.processed_directory,'not_a_real_file.txt'));
    while strcmp(errormsg,'Permission denied')
        msg = 'Cannot write to selected directory.';
        msg = [msg newline newline 'Please select different directory for saving processed data.'];
        waitfor(warndlg(msg));
        local_paths.processed_directory = get_path_ui(pwd, '', 'processed data directory', 'This is the directory where processed data from this trial will be saved to.', false, false);
        [fid, errormsg] = fopen(fullfile(local_paths.processed_directory,'not_a_real_file.txt'), 'a');
        fclose(fid);
        delete(fullfile(local_paths.processed_directory,'not_a_real_file.txt'));
    end
end

