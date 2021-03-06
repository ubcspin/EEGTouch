%% THIS CODE SHOULD WORK�??

% extracts calibrated words from CSV made by Qian

function calibrated_words_timeseries = align_calibrated_words(local_paths, trial_data)

file_name = get_path_ui(local_paths.trial_directory, 'try*.csv', 'interview+calibration csv', 'The file is usually called try-(number).csv and I do not know where you put it.', true, false);

fid = fopen(file_name, 'rt', 'n', 'UTF8');
status = fread(fid,0, '*uint8');   %adjust the 2 to fit the UTF encoding
filecontent = fread(fid, [1 inf], '*char');
datacell = textscan(filecontent, '%s', 'Delimiter', '	', 'HeaderLines', 1);
status = fclose(fid);
%datacell = textscan(filecontent, '%[\d\d(?=:)] %[(?<=:)\d\d(?=:)] %[(?<=:)\d\d(?=:)] %[(?<=:)\d\d(?=,)] %[(?<="").+(?="")] %[(?<="").+(?="")] %[(-?\d(\.\d)?)?]', 'Delimiter', '	', 'HeaderLines', 1);
%datacell = textscan(filecontent, '%s%s%s%s%s%s', 'Delimiter', '	', 'HeaderLines', 1);
a = size(datacell{1}); 
num_markers = a(1);
emotion_words = strings(num_markers,1);
calib_words = strings(num_markers,1);
calib_ms_timestamps = zeros(num_markers,1);
calib_nums = zeros(num_markers,1);
k = 1;
l = 1;
while k <= num_markers
    if (~isempty(datacell{1}{k}))
        split_cols = strsplit(datacell{1}{k}, ',');
        
        % This skips multi emotion items because I'm not sure how to encode
        % them. 
        if ~isempty(split_cols{4}) && ~isempty(regexp(split_cols{4}, '-?\d(\.\d)?', 'Match'))
            num_cell = regexp(split_cols{4}, '-?\d(\.\d)?', 'Match');
            emotion_word_cell = regexp(split_cols{2}, '(?<='').+(?='')', 'Match');
            calib_word_cell = regexp(split_cols{3}, '(?<='').+(?='')', 'Match');
            calib_nums(l) = str2num(num_cell{1});
            emotion_words(l) = emotion_word_cell{1};
            calib_words(l) = calib_word_cell{1};
            
            split_time = strsplit(split_cols{1}, ':');
            mins = split_time{2};
            secs = split_time{3};
            frames = split_time{4};
            the_timestamp = round((str2num(mins)*60*1000) + (str2num(secs)*1000) + (str2num(frames)*1000/30));
            calib_ms_timestamps(l) = the_timestamp;
            
            % Does not increment index if word is determined
            % Skips determined because of bad synonyms.
            if ~strcmp(calib_word_cell{1},'Determined')
                l = l+1;
            end
        end
    end
    k = k+1;
end

last = l-1;
calib_ms_timestamps = calib_ms_timestamps(1:last);
calib_ms_timestamps = round(calib_ms_timestamps - trial_data.scalars.sync_frame*1000/trial_data.scalars.frame_rate);

emotion_words = emotion_words(1:last);
calib_words = calib_words(1:last);
calib_nums = calib_nums(1:last);

calibrated_words_timeseries  = table(calib_ms_timestamps,emotion_words,calib_words,calib_nums,'VariableNames', {'timestamp_ms','emotion_words','calibrated_words','calibrated_values'});
