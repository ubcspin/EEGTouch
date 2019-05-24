function [trial_data, local_paths] = process_data()
    local_paths = get_local_paths();
    trial_data = load_trial_data(local_paths, struct);

    trial_data.eeg = align_eeg(local_paths, trial_data);
    save_file;
    [trial_data.fsr, trial_data.scalars.sync_frame, trial_data.scalars.frame_rate] = align_fsr_and_vidsync(local_paths, trial_data);
    save_file;
    trial_data.joystick = align_joystick(local_paths, trial_data);
    save_file;
    trial_data.interview = align_interview(local_paths, trial_data);
    save_file;
    trial_data.calibrated_words = align_calibrated_words(local_paths, trial_data);
    save_file;
    trial_data.events = align_events(local_paths, trial_data);
    save_file;
    trial_data.scenes = extract_scenes(trial_data);
    save_file;
    trial_data.frames = get_video_frames(local_paths, trial_data);
    save_file;
end