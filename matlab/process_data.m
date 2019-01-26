%function the_processed_data = process_data()

% initialize persistent variables
global trial_directory;
global processed_directory;
global trial_number;
global processed_data;

% select trial directory and navigate to it
trial_directory = get_trial_directory();
processed_directory = get_processed_directory();
processed_data = get_processed_data(processed_directory);
trial_number = get_trial_number();
cd(trial_directory);


[din_time_ms, eeg_start_time_ms] = extract_din_time();
processed_data.scalars.din_time_ms = din_time_ms;
processed_data.scalars.eeg_start_time_ms = eeg_start_time_ms;

eeg = eeg_align();
processed_data.eeg = eeg;
%plot_eeg_raw;
create_timestamped_video_excerpt;
feeltrace_align;
align_interview;
fsr_gameplay_align;
plot_all_large;
save_file;
%plot_fsr_and_feeltrace;
%save_file;
%video_face_align;
%clearvars trial_directory processed_directory trial_num
%exit_code = 0;
