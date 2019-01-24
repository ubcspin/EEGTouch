function processed_data = process_data()

% initialize persistent variables
persistent trial_directory;
persistent processed_directory;
persistent trial_number;


% select trial directory and navigate to it
trial_directory = get_path_ui(pwd, '', 'trial directory', 'This is the directory that contains one trial worth of raw data you downloaded from the server.', false);
cd(trial_directory);

% enter trial number
prompt = {'Enter trial number:'};
    title = 'Trial number';
    dims = [1 50];
    % put thing anticipating here
    definput = {'0'};
    trial_response_cell = inputdlg(prompt,title,dims,definput);
    trial_number = trial_response_cell{1};
processed_data.scalars.trial_number = trial_number;

% select processed data directory
processed_directory = get_path_ui(pwd, '', 'processed data directory', 'This is the directory where processed data from this trial will be saved to.', false);

% prompt to select new directory if this one doesn't have write permission
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

extract_din_time;
eeg_align;
%plot_eeg_raw;
create_timestamped_video_excerpt;
feeltrace_align;
align_interview;
fsr_gameplay_align;
plot_all_large;
%plot_fsr_and_feeltrace;
%save_file;
%video_face_align;
%clearvars trial_directory processed_directory trial_num
%exit_code = 0;
