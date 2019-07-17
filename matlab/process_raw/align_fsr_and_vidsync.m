function [fsr_timeseries, sync_frame, frame_rate] = align_fsr_and_vidsync(local_paths, trial_data)

    % Import FSR data and align to EEG.

    % Ensure trial directory, processed directory, trial data, are all loaded.

    % Get FSR gameplay csv - find in directory or from UI dialog.
    filename = get_path_ui(local_paths.trial_directory, 'gameplay*.csv', 'gameplay .csv file', 'The file is usually called gameplay-[number].csv and in the main trial directory.', true, false);

    % Extract one column from CSV to get length.
    A0_raw = get_numerical_csv_column(filename, 1);

    % Initialize matrix to hold raw data.
    gameplay_fromsync = zeros(length(A0_raw), 6);

    % Extract remaining columns from csv.
    gameplay_fromsync(:,1) = A0_raw;
    gameplay_fromsync(:,2) = get_numerical_csv_column(filename, 2);
    gameplay_fromsync(:,3) = get_numerical_csv_column(filename, 3);
    gameplay_fromsync(:,4) = get_numerical_csv_column(filename, 4);
    gameplay_fromsync(:,5) = get_numerical_csv_column(filename, 5);
    gameplay_fromsync(:,6) = get_numerical_csv_column(filename, 10);

    % Extract sync time and sync index from csv.
    syncs = extract_csv_sync(filename);

    % If more than one sync, find which one to use.
    [num_syncs, ~] = size(syncs);
    
    % Use video UI function to find which sync.
    if ~isfield(trial_data, 'scalars') || ~isfield(trial_data.scalars, 'sync_frame') || ~isfield(trial_data.scalars, 'frame_rate') || ~isfield(trial_data.scalars, 'which_gameplay_sync')
        [sync_frame, frame_rate, which_gameplay_sync] = ui_get_sync_frame(local_paths, num_syncs);
    else
        sync_frame = trial_data.scalars.sync_frame;
        frame_rate = trial_data.scalars.frame_rate;
        which_gameplay_sync = trial_data.scalars.which_gameplay_sync;
    end

    % Cut the "syncs" matrix correctly, obtain the row from the correct sync.
    if which_gameplay_sync > 1
        sync_pair = syncs(which_gameplay_sync,:);
    else
        sync_pair = syncs;
    end
    fsr_sync_index = sync_pair(1);%

    % Remove data from before sync.
    % Subtract epoch time offset to get time = miliseconds from sync.
    gameplay_fromsync = gameplay_fromsync(fsr_sync_index+1:end,:);
    gameplay_fromsync(:,6) = gameplay_fromsync(:,6) - gameplay_fromsync(1,6);

    % Remove duplicate entries with same timestamp.
    gameplay_fromsync = remove_time_nodiffs(gameplay_fromsync, gameplay_fromsync(:,6));

    % Remove data from timestamps after end of EEG data.
    eeg_endstamp = trial_data.eeg.timestamp_ms(end);
    ind_timestamp_after_eeg_end = find(gameplay_fromsync(:,6) > eeg_endstamp);
    if ~isempty(ind_timestamp_after_eeg_end)
        gameplay_fromsync = gameplay_fromsync(1:ind_timestamp_after_eeg_end,:);
    end

    fsr_timeseries = table(gameplay_fromsync(:,6), gameplay_fromsync(:,1), gameplay_fromsync(:,2), gameplay_fromsync(:,3), gameplay_fromsync(:,4), gameplay_fromsync(:,5), 'VariableNames', {'timestamp_ms', 'A0','A1','A2','A3','A4'});

end