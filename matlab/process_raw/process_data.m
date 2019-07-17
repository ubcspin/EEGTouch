function trial_data = process_data(local_paths, trial_data)
    init_app;

    %local_paths = get_local_paths();
    if isempty(local_paths)
        local_paths = get_local_paths();
    end
    
    if ~isfield(trial_data, 'scalars') || ~isfield(trial_data.scalars, 'trial_number')
        trial_data.scalars.trial_number = get_trial_number(false);
    end
    fprintf(['Processing trial ' char(trial_data.scalars.trial_number) '\n']);
    %trial_data = load_trial_data(local_paths, trial_data);
    %trial_data = load_trial_data(local_paths, struct);
    fprintf('Aligning EEG \n');
    trial_data.eeg = align_eeg(local_paths, trial_data);
    save_file(local_paths,trial_data);
    fprintf('Aligning FSR and syncing video \n');
    [trial_data.fsr, trial_data.scalars.sync_frame, trial_data.scalars.frame_rate] = align_fsr_and_vidsync(local_paths, trial_data);
    save_file(local_paths,trial_data);
    fprintf('Aligning joystick \n');
    trial_data.joystick = align_joystick(local_paths, trial_data);
    save_file(local_paths,trial_data);
    fprintf('Aligning inteview \n');
    trial_data.interview = align_interview(local_paths, trial_data);
    save_file(local_paths,trial_data);
    fprintf('Aligning calibrated words \n');
    trial_data.calibrated_words = align_calibrated_words(local_paths, trial_data);
    save_file(local_paths,trial_data);
    fprintf('Aligning events \n');
    trial_data.events = align_events(local_paths, trial_data);
    save_file(local_paths,trial_data);
    fprintf('Aligning scenes \n');
    trial_data.scenes = extract_scenes(trial_data);
    save_file(local_paths,trial_data);
    fprintf('Aligning video frames \n');
    trial_data.frames = get_video_frames(local_paths, trial_data);
    if ~save_file(local_paths,trial_data)
        waitfor(errordlg('Error: data could not be saved to disk.'));
    end
    fprintf(['Trial data saved to disk for trial ' char(trial_data.scalars.trial_number) ' saved to disk. \n']);
end