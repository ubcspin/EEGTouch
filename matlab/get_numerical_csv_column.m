% Gets column of numbers from CSV file.
% Non-numerical values are replaced by NaN.

function the_column = get_numerical_csv_column(file_name, column_number)
delimiter = ',';

% Status bar.
%f = waitbar(0.7,'Importing FSR data','Name','Data Processing');

% Read columns of data as text:
formatSpec = [repmat('%*s',1,column_number-1) '%s%[^\n\r]'];

% '%*s%s%[^\n\r]';
% '%*q%*q%q%[^\n\r]';
% '%*q%*q%*q%q%[^\n\r]';
% '%*q%*q%*q%*q%q%[^\n\r]';
% '%*q%*q%*q%*q%*q%*q%*q%*q%*q%q%[^\n\r]';

% Open the csv text file.
fileID = fopen(file_name,'r');
% Read columns of data according to the format.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string',  'ReturnOnError', false);
% Close the csv text file.
fclose(fileID);

% Convert the contents of columns containing numeric text to numbers.
% Replace non-numeric text with NaN.
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = mat2cell(dataArray{col}, ones(length(dataArray{col}), 1));
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));
rawData = dataArray{1};
raw = str2double(rawData);

the_column = raw;
% Create output variable
% gameplay_A0 = table;
% gameplay_A0.A0 = raw;
% the_column = [];