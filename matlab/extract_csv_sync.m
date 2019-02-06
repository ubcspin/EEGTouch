% Gets sync index and sync epochtime from gameplay csv file
function sync_output = extract_csv_sync(file_name)
delimiter = ',';
% Read columns of data as text:
formatSpec = '%s%[^\n\r]';
% Open the csv text file.
fileID = fopen(file_name,'r');
% Read columns of data according to the format.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string',  'ReturnOnError', false);
% Close the csv text file.
fclose(fileID);

% Find indices of syncs.
sync_indices = find(strlength(dataArray{1}) > 4);
% Find strings at sync indices.
sync_strings = dataArray{1}(sync_indices);
% Split strings to find epochtimes in string format
sync_epochtimes_split = split(sync_strings,"t");
% Take just the latter part of the split.
if length(sync_strings) > 1
    sync_epochtimes_str = sync_epochtimes_split(:,2);
else
    sync_epochtimes_str = sync_epochtimes_split(2);
end
% Convert epochtimes into numbers.
sync_epochtimes = str2num(sync_epochtimes_str);

sync_output = [sync_indices sync_epochtimes]