% Gets sync index and sync epochtime from gameplay csv file
function [sync_index, sync_epochtime] = extract_csv_sync(file_name, which_sync)
delimiter = ',';
% Read columns of data as text:
formatSpec = '%s%[^\n\r]';
% Open the csv text file.
fileID = fopen(file_name,'r');
% Read columns of data according to the format.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string',  'ReturnOnError', false);
% Close the csv text file.
fclose(fileID);
if (which_sync == 1)
    sync_index = find(strlength(dataArray{1}) > 4);
else
    sync_indices = find(strlength(dataArray{1}) > 4);
    if which_sync > length(sync_indices)
        throw(MException('Custom:Custom',['Failure: Sync index provided exceeds number of sync signals in csv file']));
    end
    sync_index = sync_indices(which_sync);
end
sync_string = dataArray{1}(sync_index);
sync_epochtime_split = strsplit(sync_string,'t');
sync_epochtime = str2double(sync_epochtime_split(end));
end