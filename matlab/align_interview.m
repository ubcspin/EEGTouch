%extract unique-timestamp interview data and timestamps
%and compile concise array
%name of interview file

% Ensure trial directory, processed directory, processed data, etc. all
% loaded.
load_globals;

% Get the CSV file for the interview.
interview_file = get_path_ui(trial_directory, 'interview*.csv', 'interview csv', 'The file is usually called intervew-[number].csv and in the main trial directory.', true);

% Extract data from CSV
interview_table = get_premiere_markers(interview_file);

% Align video millisecond timestamp to sync frame.
interview_table.timestamp_ms = round(interview_table.timestamp_ms - processed_data.scalars.sync_frame*1000/processed_data.scalars.frame_rate);

% Add to processed data struct.
processed_data.interview = interview_table;

% Save processed data.
save_file;

clearvars interview_file interview_table;