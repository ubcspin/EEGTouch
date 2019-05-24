% extract unique-timestamp feeltrace data, sync feeltrace timestamps
% and compile concise array of feeltrace data and timestamps
% name of feeltrace file
% If no trial directory variable, try current directory.
%load_globals;
function joystick_timeseries = align_joystick(local_paths, trial_data)

    % Get csv - find in directory or from UI dialog.
    filename = get_path_ui(local_paths.trial_directory, 'feeltrace*.csv', 'feeltrace .csv file', 'The file is usually called feeltrace-[number].csv and in the main trial directory.',true, false);

    % Extract feeltrace and video timestamp columns from csv
    joystick_readings = get_numerical_csv_column(filename, 6);
    joystick_timestamps = get_numerical_csv_column(filename, 9);

    % copy over raw data, remove header row
    joystick_readings = joystick_readings(2:end);
    joystick_timestamps = joystick_timestamps(2:end);


    % find where video actually starts playing, remove data before
    % vid_start_index = find(feeltrace_videoTimestamp > 0, 1)+1;
    % feeltrace_joystick = feeltrace_joystick(vid_start_index:end);
    % feeltrace_videoTimestamp = feeltrace_videoTimestamp(vid_start_index:end);

    vid_start_index = find(joystick_timestamps >0, 1)+1;
    joystick_readings = joystick_readings(vid_start_index:end);
    joystick_timestamps = joystick_timestamps(vid_start_index:end);

    % convert to milliseconds, subtract sync offset and round to integer
    joystick_timestamps = round((joystick_timestamps*1000 - (trial_data.scalars.sync_frame*1000 / trial_data.scalars.frame_rate)));

    % transpose joystick data: subtract minimum
    joystick_readings = joystick_readings - min(joystick_readings);

    % average rows with same timestamp
    joystick_readings_and_timestamps_mat = remove_time_nodiffs(horzcat(joystick_readings, joystick_timestamps), joystick_timestamps);

    joystick_timeseries = table(joystick_readings_and_timestamps_mat(:,2), joystick_readings_and_timestamps_mat(:,1),'VariableNames', {'timestamp_ms' 'joystick'});

    %processed_data.feeltrace = feeltrace_condensed;

end
%clearvars feeltrace_condensed feeltrace_file feeltrace_joystick feeltrace_round_times_ms feeltrace_videoTimestamp filename nodiffs vid_start_index