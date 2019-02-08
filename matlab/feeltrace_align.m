% extract unique-timestamp feeltrace data, sync feeltrace timestamps
% and compile concise array of feeltrace data and timestamps
% name of feeltrace file
% If no trial directory variable, try current directory.
load_globals;

% Get csv - find in directory or from UI dialog.
feeltrace_file = get_path_ui(trial_directory, 'feeltrace*.csv', 'feeltrace .csv file', 'The file is usually called feeltrace-[number].csv and in the main trial directory.',true);
filename = feeltrace_file;

% Extract feeltrace and video timestamp columns from csv
feeltrace_joystick = get_numerical_csv_column(filename, 6);
feeltrace_videoTimestamp = get_numerical_csv_column(filename, 9);

% copy over raw data, remove header row
feeltrace_joystick = feeltrace_joystick(2:end);
feeltrace_videoTimestamp = feeltrace_videoTimestamp(2:end);


% find where video actually starts playing, remove data before
% vid_start_index = find(feeltrace_videoTimestamp > 0, 1)+1;
% feeltrace_joystick = feeltrace_joystick(vid_start_index:end);
% feeltrace_videoTimestamp = feeltrace_videoTimestamp(vid_start_index:end);

vid_start_index = find(feeltrace_videoTimestamp >0, 1)+1;
feeltrace_joystick = feeltrace_joystick(vid_start_index:end);
feeltrace_videoTimestamp = feeltrace_videoTimestamp(vid_start_index:end);

% convert to milliseconds, subtract sync offset and round to integer
feeltrace_round_times_ms = round((feeltrace_videoTimestamp*1000 - (processed_data.scalars.sync_frame*1000 / processed_data.scalars.frame_rate)));

% transpose joystick data: subtract minimum
feeltrace_joystick = feeltrace_joystick - min(feeltrace_joystick);

% average rows with same timestamp
nodiffs = remove_time_nodiffs(horzcat(feeltrace_joystick, feeltrace_round_times_ms), feeltrace_round_times_ms);

feeltrace_condensed = table(nodiffs(:,2), nodiffs(:,1),'VariableNames', {'timestamp_ms' 'joystick'});

processed_data.feeltrace = feeltrace_condensed;

clearvars feeltrace_condensed feeltrace_file feeltrace_joystick feeltrace_round_times_ms feeltrace_videoTimestamp filename nodiffs vid_start_index