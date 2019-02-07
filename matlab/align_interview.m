%extract unique-timestamp interview data and timestamps
%and compile concise array
%name of interview file

load_globals;

interview_name = get_path_ui(pwd, 'interview*.csv', 'interview csv', 'The file is usually called intervew-[number].csv and in the main trial directory.', true);

fid = fopen(interview_name, 'rt', 'n', 'ascii');
fread(fid, 2, '*uint8');   %adjust the 2 to fit the UTF encoding
filecontent = fread(fid, [1 inf], '*char');
datacell = textscan(filecontent, '%s%s%s%s%s%s', 'Delimiter', ',', 'HeaderLines', 1);
a = size(datacell{1}); 
num_markers = a(1);
% interview_comments = strings(num_markers);
interview_ms_timestamps = zeros(num_markers,1);
interview_scales = zeros(num_markers, 1);
k = 1;
l = 1;
while k <= num_markers
    if (~isempty(datacell{1}{k}) && ~(datacell{1}{k} == ""))
        int_timestamp_strings = strsplit(datacell{1}{k}, ':');
        mins = int_timestamp_strings(2);
        secs = int_timestamp_strings(3);
        frames = int_timestamp_strings(4);
        int_timestamp = round((str2num(mins{1})*60*1000) + (str2num(secs{1})*1000) + (str2num(frames{1})*1000/30));
        if ~(int_timestamp == 0)
            interview_ms_timestamps(l) = int_timestamp;
%             interview_comments(l) = datacell{2}{l};
            if datacell{2}{l} == ""
                interview_scales(l) = 11;
            else
                interview_scales(l) = str2num(datacell{2}{l});
            end
            l = l+1;
        end
    end
    k = k+1;
end

interview_ms_timestamps = interview_ms_timestamps(1:find(interview_ms_timestamps,1,'last'));
% interview_comments = interview_comments(1:length(interview_ms_timestamps));
interview_scales = interview_scales(1:length(interview_ms_timestamps));
interview_ms_timestamps = round(interview_ms_timestamps - processed_data.scalars.sync_frame*1000 / processed_data.scalars.frame_rate);
interview_table = table(interview_ms_timestamps, interview_scales, 'VariableNames', {'timestamp_ms','label'});
processed_data.interview = interview_table;
