function [exit_code] = process_data()
clearvars
exit_code = 1;
global trial_directory;
global processed_directory;
global trial_number
addpath(pwd);
waitfor(warndlg("Please find the directory containing raw trial data to process."));
trial_directory = uigetdir(path,"Select directory containg raw data from one trial");
oldpath = path;
cd(trial_directory);
path(oldpath,path);
prompt = {'Enter trial number:'};
    title = 'Trial number';
    dims = [1 35];
    definput = {'0'};
    trial_number = inputdlg(prompt,title,dims,definput);
processed_dir_name = "processed_data_" + trial_number;
status = mkdir(sprintf(processed_dir_name));
processed_directory = fullfile(trial_directory, processed_dir_name);
while (~status) 
    if strcmp(questdlg('Unable to write processed data directory to trial directory. Find other directory to save in?',''),'Yes')
        waitfor(warndlg("Please select a parent directory for the processed data directory to be saved to."));
        parent_dir = uigetdir(trial_directory, "Select parent directory for saving processed data");
        status = mkdir(sprintf(processed_dir_name));
        processed_directory = fullfile(parent_dir, processed_dir_name);
    else
        throw(MException('Custom:Custom','Failure: no directory chosen to write processed data'));
    end
end

extract_din_time;
eeg_align;
plot_eeg_raw;
create_timestamped_video_excerpt;
feeltrace_align;
fsr_gameplay_align;
plot_fsr_and_feeltrace;
save_file;
%video_face_align;
clearvars trial_directory processed_directory trial_num
exit_code = 0;
