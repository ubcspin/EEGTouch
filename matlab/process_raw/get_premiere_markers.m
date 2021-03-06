%% extract data from an Adobe Premiere marker CSV.
%  Output as a table.

function marker_table  = get_premiere_markers(file_name)

% Extract text from the csv file.
fid = fopen(file_name, 'rt', 'n', 'UTF16LE');
status = fread(fid, 2, '*uint8');   %adjust the 2 to fit the UTF encoding
filecontent = fread(fid, [1 inf], '*char');
%datacell = textscan(filecontent, '%s%s%s%s%s%s', 'Delimiter', '	', 'HeaderLines', 1);
datacell = textscan(filecontent, '%q%q%q%q%q%q', 'Delimiter', '	', 'HeaderLines', 1);
status = fclose(fid);
a = size(datacell{1}); 
num_markers = a(1);
csv_comments = strings(num_markers);
csv_ms_timestamps = zeros(num_markers,1);

% Iterate through markers, process timestamps, and extract comments.
i = 1;
j = 1;
while i <= num_markers
    % Ignore markers with empty comments.
    if ~isempty(datacell{1}{i}) && ~(datacell{1}{i} == "") && ~isempty(datacell{3}{i}) && ~(datacell{3}{i} == "")
        % Process time in Premiere format to milliseconds.
        int_timestamp_strings = strsplit(datacell{3}{i}, ':');
        % for some reason some timestamps from premiere are separated by
        % colons, but others are separated by semicolons? idk why?
        % anyway this deals w/both
        if length(int_timestamp_strings) == 1
            int_timestamp_strings = strsplit(datacell{3}{i}, ';');
        end
        mins = int_timestamp_strings(2);
        secs = int_timestamp_strings(3);
        frames = int_timestamp_strings(4);
        int_timestamp = round((str2num(mins{1})*60*1000) + (str2num(secs{1})*1000) + (str2num(frames{1})*1000/30));
        % Ignore timestamps at 0:00.
        if ~(int_timestamp == 0)
            csv_ms_timestamps(j) = int_timestamp;
            csv_comments(j) = datacell{1}{i};
            j = j+1;
        end
    end
    i = i+1;
end

csv_ms_timestamps = csv_ms_timestamps(1:find(csv_ms_timestamps,1,'last'));
csv_comments = csv_comments(1:length(csv_ms_timestamps));

marker_table = table(csv_ms_timestamps, csv_comments.', 'VariableNames', {'timestamp_ms','label'});

end
