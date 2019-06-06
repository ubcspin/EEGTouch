% Align play markers.

% Ensure trial directory, processed directory, processed data, etc. all
% loaded.
function events_timeseries = align_events(local_paths, trial_data)

    % Get the CSV files for the events.
    qual_directory = get_path_ui(local_paths.trial_directory, 'qual*', 'qualitative data directory', 'This is the directory that contains the qualitative data (event coding CSVs). On the server, it is a subdirectory of a trial raw data directory.',false, false);
    game_file = get_path_ui(qual_directory, 'game*.csv', 'game events csv', 'The file is usually called game-[number]-[coder].csv and in the qual-data-p[number] subdirectory of the main trial directory.', true, false);
    character_file = get_path_ui(qual_directory, 'character*.csv', 'character events csv', 'The file is usually called character-[number]-[coder].csv and in the qual-data-p[number] subdirectory of the main trial directory.', true, false);
    sound_file = get_path_ui(qual_directory, 'sound*.csv', 'sound events csv', 'The file is usually called sound-[number]-[coder].csv and in the qual-data-p[number] subdirectory of the main trial directory.', true, false);

    % Extract data from CSV
    game_table = get_premiere_markers(game_file);
    game_table.label = lower(game_table.label);
    character_table = get_premiere_markers(character_file);
    character_table.label = lower(character_table.label);
    sound_table = get_premiere_markers(sound_file);
    sound_table.label = lower(sound_table.label);

    % Align video millisecond timestamps to sync frame.
    game_table.timestamp_ms = round(game_table.timestamp_ms - trial_data.scalars.sync_frame*1000 / trial_data.scalars.frame_rate);
    character_table.timestamp_ms = round(character_table.timestamp_ms - trial_data.scalars.sync_frame*1000 / trial_data.scalars.frame_rate);
    sound_table.timestamp_ms = round(sound_table.timestamp_ms - trial_data.scalars.sync_frame*1000 / trial_data.scalars.frame_rate);

    % Add to processed data struct.
    events_timeseries.game_controlled_visual = game_table;
    events_timeseries.game_controlled_sound = sound_table;
    events_timeseries.player_controlled = character_table;
end