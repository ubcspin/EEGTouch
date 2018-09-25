%name of eeg file
eeg_file = dir('*2018*.mat');
if ~isempty(eeg_file)
    eeg_name = eeg_file.name;
    oldpath = path;
    path(oldpath,eeg_file.folder);
else
    waitfor(warndlg('Unable to automatically locate EEG Matlab data for this trial. Please find it manually. The file is usually named with a date and time stamp with the extension .mat and in the main trial directory.'));
    [eeg_name, eeg_path] = uigetfile('*.mat','Find EEG data Matlab file');
    oldpath = path;
    path(oldpath,eeg_path);
    isdlg = 'No';
    while (eeg_name(1) == 0) && strcmp(questdlg('No EEG Matlab data file was opened. Do you want to keep looking for this file yourself?',''),'Yes')
           [eeg_name, eeg_path] = uigetfile('*.mat','Find EEG data Matlab file');
            oldpath = path;
            path(oldpath,eeg_path);
    end
    if eeg_name(1) == 0
        waitfor(errordlg('Aborting data processing: no valid EEG Matlab data file'));
        throw(MException('Custom:Custom','Failure: unable to find valid EEG data file'));
    end
end

f = waitbar(0.1,'Aligning EEG data','Name','Data Processing');

load(eeg_name);

% find name of eeg data variable
% yes, this is weird. it's okay. adapted from matlab guide.
varnames = who('*mff');
values = cellfun(@eval, varnames, 'UniformOutput', false);
cell2table([varnames, values], 'VariableNames', {'Variable', 'Value'});

%crop eeg data to din sync (as extracted in 'extract_din_times')
eeg_data_synced = values{1};
eeg_data_synced = eeg_data_synced(:,(scalars.din_time_ms-scalars.eeg_start_time_ms)/1000:end);

%add a column for millisecond timestamp to synced eeg data
eeg_data_synced = vertcat(ones(1, length(eeg_data_synced(65,:))), eeg_data_synced);
eeg_data_synced(1,1) = 0;
eeg_data_synced(1,:) = cumsum(eeg_data_synced(1,:));

aligned_data(1).timestamp_ms = 0;
aligned_data(1).eeg = zeros(65,1);

%put eeg data into aligned_data superarray
for k=1:length(eeg_data_synced(65,:))
    aligned_data(k).timestamp_ms = eeg_data_synced(1,k);
    aligned_data(k).eeg = eeg_data_synced(2:66,k);
end

close(f);
clearvars f eeg_path values varnames eeg_file eeg_name isdlg;