%interview_filename = 'interview-17.csv';

%extract unique-timestamp interview data and timestamps
%and compile concise array
%name of interview file
if (~exist('trial_directory'))
    waitfor(warndlg('Unknown trial directory. Please select trial directory.'));
    trial_directory = uigetdir(path,"Select directory containg raw data from the trial");
end
if (~exist('processed_directory'))
    waitfor(warndlg('Unknown processed data directory. Please select processed data directory.'));
    processed_directory = uigetdir(path,"Select directory to save processed data in.");
end
if ~exist('aligned_data')
        data_file = dir(fullfile(processed_directory,'processed_data.mat'));
    if ~isempty(data_file)
        data_name = data_file.name;
        data_path = data_file.folder;
    else
        waitfor(warndlg('Unable to automatically locate processed data file for this trial. Please find it manually. The file is usually called processed_data.mat and in the processed data directory. If the data from this trial has not been processed, please process data instead of running this script alone.'));
        [data_name, data_path] = uigetfile('*.mat','Find processed data .mat file');
        isdlg = 'No';
        while (data_name(1) == 0) && strcmp(questdlg('No processed data matlab file was opened. If the data from this trial has not been processed, please process data instead of running this script alone. Do you want to keep looking for this file yourself?',''),'Yes')
            [data_name, data_path] = uigetfile('*.mat','Find processed data .mat file');
        end
        if data_name(1) == 0
            waitfor(errordlg('Aborting data processing: no processed data file'));
            throw(MException('Custom:Custom','Failure: unable to find processed data file to add interview timestamps to'));
        end
    end

    if ~contains(data_name,pathsep)
        data_name = fullfile(data_path,data_name);
    end
    load (data_name);
end

interview_file = dir(fullfile(trial_directory,'interview*.csv'));
if ~isempty(interview_file)
    interview_name = interview_file.name;
    interview_path = interview_file.folder;
else
    waitfor(warndlg('Unable to automatically locate interview data for this trial. Please find it manually. The file is usually called intervew-[number].csv and in the main trial directory.'));
    [interview_name, interview_path] = uigetfile('*.csv','Find inteview csv');
    isdlg = 'No';
    while (interview_name(1) == 0) && strcmp(questdlg('No interview csv was opened. Do you want to keep looking for this file yourself?',''),'Yes')
       [interview_name, interview_path] = uigetfile('*.csv','Find interview csv');
    end
    if interview_name(1) == 0
        waitfor(errordlg('Aborting data processing: no valid interview csv file'));
        throw(MException('Custom:Custom','Failure: unable to find valid interview csv file'));
    end
end

if ~contains(interview_name,pathsep)
    interview_name = fullfile(interview_path,interview_name);
end

f = waitbar(0.5,'Importing interview data','Name','Data Processing');

fid = fopen(interview_name, 'rt', 'n', 'UTF16LE');
fread(fid, 2, '*uint8');   %adjust the 2 to fit the UTF encoding
filecontent = fread(fid, [1 inf], '*char');
datacell = textscan(filecontent, '%s%s%s%s%s%s', 'Delimiter', '	', 'HeaderLines', 1);
a = size(datacell{1}); 
num_markers = a(1);
interview_comments = strings(num_markers);
interview_ms_timestamps = zeros(num_markers,1);
for k = 1:num_markers
    if ~(datacell{3}{k} == "")
        interview_comments(k) = datacell{1}{k};
        int_timestamp_strings = strsplit(datacell{3}{k}, ':');
        mins = int_timestamp_strings(2);
        secs = int_timestamp_strings(3);
        frames = int_timestamp_strings(4);
        int_timestamp = round((str2num(mins{1})*60*1000) + (str2num(secs{1})*1000) + (str2num(frames{1})*1000/30));
        interview_ms_timestamps(k) = int_timestamp;
    end
end

interview_ms_timestamps = round(interview_ms_timestamps - scalars.sync_frame*1000 / scalars.frame_rate);

%align feeltrace data to master array
aligned_data(1).interview = [];
l = 1;
a = length(interview_ms_timestamps);
for k=1:length([aligned_data.timestamp_ms])
    if l > a
        break;
    end
    if interview_ms_timestamps(l) == aligned_data(k).timestamp_ms
        aligned_data(k).interview =interview_comments(l);
        l = l+1;
    else
        aligned_data(k).interview = [];
    end  
end

save(fullfile(processed_directory, 'processed_data.mat'),'aligned_data', 'scalars');
close(f);