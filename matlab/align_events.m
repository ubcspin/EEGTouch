% Align play markers.

% Ensure trial directory, processed directory, processed data, etc. all
% loaded.
load_globals;

% Get the CSV files for the events.
qual_directory = get_path_ui(trial_directory, 'qual*', 'qualitative data directory', 'This is the directory that contains the qualitative data (event coding CSVs). On the server, it is a subdirectory of a trial raw data directory.',false);
game_file = get_path_ui(qual_directory, 'game*.csv', 'game events csv', 'The file is usually called game-[number]-[coder].csv and in the qual-data-p[number] subdirectory of the main trial directory.', true);
character_file = get_path_ui(qual_directory, 'character*.csv', 'character events csv', 'The file is usually called character-[number]-[coder].csv and in the qual-data-p[number] subdirectory of the main trial directory.', true);
sound_file = get_path_ui(qual_directory, 'sound*.csv', 'sound events csv', 'The file is usually called sound-[number]-[coder].csv and in the qual-data-p[number] subdirectory of the main trial directory.', true);

% Extract data from CSV
game_table = get_premiere_markers(game_file);
character_table = get_premiere_markers(character_file);
sound_table = get_premiere_markers(sound_file);

% Align video millisecond timestamps to sync frame.
game_table.timestamp_ms = round(game_table.timestamp_ms - processed_data.scalars.sync_frame*1000 / processed_data.scalars.frame_rate);
character_table.timestamp_ms = round(character_table.timestamp_ms - processed_data.scalars.sync_frame*1000 / processed_data.scalars.frame_rate);
sound_table.timestamp_ms = round(sound_table.timestamp_ms - processed_data.scalars.sync_frame*1000 / processed_data.scalars.frame_rate);

% Add to processed data struct.
processed_data.events.game = game_table;
processed_data.events.character = character_table;
processed_data.events.sound = sound_table;

% Save processed data.
save_file;

clearvars game_file game_table sound_file sound_table character_file character_table;

% % Extract text from the csv file.
% fid = fopen(interview_name, 'rt', 'n', 'UTF16LE');
% status = fread(fid, 2, '*uint8');   %adjust the 2 to fit the UTF encoding
% filecontent = fread(fid, [1 inf], '*char');
% datacell = textscan(filecontent, '%s%s%s%s%s%s', 'Delimiter', '	', 'HeaderLines', 1);
% status = fclose(fid);
% a = size(datacell{1}); 
% num_markers = a(1);
% interview_comments = strings(num_markers);
% interview_ms_timestamps = zeros(num_markers,1);
% 
% % Iterate through markers, process timestamps, and extract comments.
% k = 1;
% l = 1;
% while k <= num_markers
%     % Ignore markers with empty comments.
%     if (~isempty(datacell{3}{k}) && ~(datacell{3}{k} == ""))
%         % Process time in Premiere format to milliseconds.
%         int_timestamp_strings = strsplit(datacell{3}{k}, ':');
%         mins = int_timestamp_strings(2);
%         secs = int_timestamp_strings(3);
%         frames = int_timestamp_strings(4);
%         int_timestamp = round((str2num(mins{1})*60*1000) + (str2num(secs{1})*1000) + (str2num(frames{1})*1000/30));
%         % Ignore timestamps at 0:00.
%         if ~(int_timestamp == 0)
%             interview_ms_timestamps(l) = int_timestamp;
%             interview_comments(l) = datacell{1}{l};
%             l = l+1;
%         end
%     end
%     k = k+1;
% end
% 
% interview_ms_timestamps = interview_ms_timestamps(1:find(interview_ms_timestamps,1,'last'));
% interview_comments = interview_comments(1:length(interview_ms_timestamps));
% % Align using sync frame and round to nearest millisecond.
% interview_ms_timestamps = round(interview_ms_timestamps - processed_data.scalars.sync_frame*1000 / processed_data.scalars.frame_rate);
% 
% interview_table = table(interview_ms_timestamps, interview_comments.', 'VariableNames', {'timestamp_ms','label'});
% 
% processed_data.interview = interview_table;
% 
% clearvars a datacell fid filecontent frames int_timestamp int_timestamp_strings interview_comments interview_ms_timestamps interview_name interview_table k l mins num_markers secs status