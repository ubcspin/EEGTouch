%extract unique-timestamp feeltrace data, sync feeltrace timestamps
%and compile concise array of feeltrace data and timestamps
%name of feeltrace file
feeltrace_file = dir('feeltrace*.csv');
if ~isempty(feeltrace_file)
    feeltrace_name = feeltrace_file.name;
    feeltrace_path = feeltrace_file.folder;
else
    waitfor(warndlg('Unable to automatically locate feeltrace data for this trial. Please find it manually. The file is usually called feeltrace-[number].csv and in the main trial directory.'));
    [feeltrace_name, feeltrace_path] = uigetfile('*.csv','Find feeltrace csv');
    isdlg = 'No';
    while (feeltrace_name(1) == 0) && strcmp(questdlg('No feeltrace csv was opened. Do you want to keep looking for this file yourself?',''),'Yes')
       [feeltrace_name, feeltrace_path] = uigetfile('*.csv','Find feeltrace csv');
    end
    if feeltrace_name(1) == 0
        waitfor(errordlg('Aborting data processing: no valid feeltrace csv file'));
        throw(MException('Custom:Custom','Failure: unable to find valid feeltrae csv file'));
    end
end

if ~contains(feeltrace_name,pathsep)
    feeltrace_name = fullfile(feeltrace_path,feeltrace_name);
end

f = waitbar(0.5,'Importing feeltrace data','Name','Data Processing');

%% Initialize variables.
filename = feeltrace_name;
delimiter = ',';

%% Read columns of data as text:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%*q%*q%*q%*q%*q%q%*q%*q%q%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to the format.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string',  'ReturnOnError', false);

%% Close the text file.
fclose(fileID);

%% Convert the contents of columns containing numeric text to numbers.
% Replace non-numeric text with NaN.
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = mat2cell(dataArray{col}, ones(length(dataArray{col}), 1));
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[1,2]
    % Converts text in the input cell array to numbers. Replaced non-numeric
    % text with NaN.
    rawData = dataArray{col};
    for row=1:size(rawData, 1)
        % Create a regular expression to detect and remove non-numeric prefixes and
        % suffixes.
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData(row), regexstr, 'names');
            numbers = result.numbers;
            
            % Detected commas in non-thousand locations.
            invalidThousandsSeparator = false;
            if numbers.contains(',')
                thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(numbers, thousandsRegExp, 'once'))
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % Convert numeric text to numbers.
            if ~invalidThousandsSeparator
                numbers = textscan(char(strrep(numbers, ',', '')), '%f');
                numericData(row, col) = numbers{1};
                raw{row, col} = numbers{1};
            end
        catch
            raw{row, col} = rawData{row};
        end
    end
end


%% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw); % Find non-numeric cells
raw(R) = {NaN}; % Replace non-numeric cells

%% Create output variable
feeltrace = table;
feeltrace.A5 = cell2mat(raw(:, 1));
feeltrace.videoTimestamp = cell2mat(raw(:, 2));

%% Clear temporary variables
clearvars filename delimiter formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp R;

waitbar(0.6,f,'Aligning feeltrace data','Name','Data Processing');


%copy over raw data, remove header row
feeltrace_joystick = feeltrace.A5(2:end);
feeltrace_videoTimestamp = feeltrace.videoTimestamp(2:end);

%find where video actually starts playing, remove data before
vid_start_index = find(feeltrace_videoTimestamp ~= -1, 1)+1;
feeltrace_joystick = feeltrace_joystick(vid_start_index:end);
feeltrace_videoTimestamp = feeltrace_videoTimestamp(vid_start_index:end);

%convert to milliseconds, subtract sync offset and round to integer
feeltrace_round_times_ms = round((feeltrace_videoTimestamp*1000 - (scalars.sync_frame*1000 / scalars.frame_rate)));
%array of indices where video timestamp is in differend millisecond
feeltrace_vidTimeChanged = ischange(feeltrace_round_times_ms);

%transpose joystick data: subtract minimum
feeltrace_joystick = feeltrace_joystick - min(feeltrace_joystick);

%array of indices where video timestamp is in different millisecond
changept_indices = vertcat(1, find(feeltrace_vidTimeChanged));

%prepare array of compiled joystick values for unique timestamps
con_joystick = zeros(length(changept_indices),1);
%and array of unique video timestamps
con_vidTimestamp = zeros(length(changept_indices),1);

%populate arrays
for k = 1:length(changept_indices)-1
    con_joystick(k) = median(feeltrace_joystick(changept_indices(k):changept_indices(k+1)-1));
    con_vidTimestamp(k) = feeltrace_round_times_ms(changept_indices(k));
end

%collect data into table
feeltrace_condensed = table(con_vidTimestamp, con_joystick, 'VariableNames', {'timestamp_ms' 'joystick'});
feeltrace_condensed = feeltrace_condensed(1:find(feeltrace_condensed.timestamp_ms == 0, 1)-1,:);

%align feeltrace data to master array
aligned_data(1).feeltrace = [];
l = 1;
a = length(feeltrace_condensed.joystick);
for k=1:length([aligned_data.timestamp_ms])
    if l > a
        break;
    end
    if feeltrace_condensed.timestamp_ms(l) == aligned_data(k).timestamp_ms
        aligned_data(k).feeltrace = feeltrace_condensed.joystick(l);
        l = l+1;
    else
        aligned_data(k).feeltrace = [];
    end  
end
close(f);
%clear excess variables
clearvars f feeltrace_condensed feeltrace_file feeltrace_path k a isdlg feeltrace_name feeltrace feeltrace_joystick feeltrace_videoTimestamp vid_start_index feeltrace_round_times_ms feeltrace_vidTimeChanged changept_indices con_joystick con_vidTimestamp l;