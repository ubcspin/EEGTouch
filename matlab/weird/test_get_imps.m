% loc = parent dir of eegraw dirs
loc = 'C:\Users\laura\Documents\SPIN\EEG_data';

dirs = dir(fullfile(loc,'raw','*'));

names = strings(19,1);

for i = 3:22
    names(i-2) = dirs(i).name;
end

imps = zeros(length(names),66);
if ~exist('file_names','var')
    file_names = strings(length(names),1);
end
xes = 1:66;
hold on;
for i = 1:length(names) 
    %eeg_name = dir(fullfile(loc,'raw',names(i+2),'*201*.mat'));
    if file_names(i) == ""
        eeg_name = get_path_ui(fullfile(loc,'raw',names(i)), '*201*.mat', 'EEG Matlab file', 'Find the correct EEG Matlab file in this trial directory', true);
        file_names(i) = eeg_name;
    else
        eeg_name = file_names(i);
    end
    %eeg_name = get_path_ui(fullfile(loc,'raw',names(i)), '*201*.mat', 'EEG Matlab file', 'Find the correct EEG Matlab file in this trial directory', true);
    load(eeg_name);
    imps(i, :) = Impedances_EEG_0;clearvars -regexp .+mff*
    scatter(xes, imps(i,:));
    %a = "a";
end


clearvars -regexp ^evt.+
clearvars EEGSamplingRate Impedances_EEG_0 loc names dirs i eeg_name