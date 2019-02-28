load_globals;
f = waitbar(0.05,'Extracting din time');
extract_din_time;
waitbar(0.1,f,'Aligning EEG data');
eeg_align;
waitbar(0.2,f,'Extracting video sync');
create_timestamped_video_excerpt;
waitbar(0.3,f,'Aligning feeltrace');
feeltrace_align;
waitbar(0.5,f,'Aligning interview');
align_interview;
waitbar(0.55,f,'Aligning FSRs');
fsr_gameplay_align;
waitbar(0.75,f,'Plotting data');
plot_all_large;
waitbar(0.8,f,'Aligning calibrated words');
align_calibrated_words;
waitbar(0.85,f,'Aligning events');
align_events;
waitbar(0.90,f,'Plotting calibrated words');
import_labels;
set_scenes;
tract_scenes;
pull_vid_frames;
plot_words_and_ft_2;
waitbar(0.95,f,'Saving file');
save_file;
waitbar(1,f,'Complete!');
close(f);
msgbox('Data processing completed!','Done!');
