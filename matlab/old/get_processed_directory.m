if ~exist('processed_directory', 'var')
    directory_type = 'processed data directory';
    directory_helpmessage = 'This is the directory where processed data from this trial will be saved to.';
    processed_directory = get_path_ui(pwd, '', directory_type, directory_helpmessage,false);
end
[fid, errormsg] = fopen(fullfile(processed_directory,'not_a_real_file.txt'), 'a');
fclose(fid);
delete(fullfile(processed_directory,'not_a_real_file.txt'));
while strcmp(errormsg,'Permission denied')
    msg = 'Cannot write to selected directory.';
    msg = [msg newline newline 'Please select different directory for saving processed data.'];
    waitfor(warndlg(msg));
    processed_directory = get_path_ui(pwd, '', 'processed data directory', 'This is the directory where processed data from this trial will be saved to.', false);
    [fid, errormsg] = fopen(fullfile(processed_directory,'not_a_real_file.txt'), 'a');
    fclose(fid);
    delete(fullfile(processed_directory,'not_a_real_file.txt'));
end