%extract unique-timestamp interview data and timestamps
%and compile concise array
%name of interview file

% Ensure trial directory, processed directory, processed data, etc. all
% loaded.
function interview_timeseries = align_interview(local_paths, trial_data)

% Get the CSV file for the interview.
interview_file = get_path_ui(local_paths.trial_directory, 'interview*.csv', 'interview csv', 'The file is usually called intervew-[number].csv and in the main trial directory.', true, false);

% Extract data from CSV
interview_timeseries = get_premiere_markers(interview_file);

% Align video millisecond timestamp to sync frame.
interview_timeseries.timestamp_ms = round(interview_timeseries.timestamp_ms - trial_data.scalars.sync_frame*1000/trial_data.scalars.frame_rate);

end