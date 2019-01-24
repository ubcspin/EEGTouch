% Import FSR data and align to EEG.

% If no trial directory variable, try current directory.
if ~exist('trial_directory')
    trial_directory = pwd;
end

% Get FSR gameplay csv - find in directory or from UI dialog.
fsr_file = get_path_ui(trial_directory, 'gameplay*.csv', 'gameplay .csv file', 'The file is usually called gameplay-[number].csv and in the main trial directory.', true);
filename = fsr_file;

% Extract one column from CSV to get length.
A0_raw = get_numerical_csv_column(filename, 1);

% Initialize matrix to hold raw data.
gameplay_fromsync = zeros(length(A0_raw), 6);

% Extract remaining columns from csv.
gameplay_fromsync(:,6) = get_numerical_csv_column(filename, 10);
gameplay_fromsync(:,1) = A0_raw;
gameplay_fromsync(:,2) = get_numerical_csv_column(filename, 2);
gameplay_fromsync(:,3) = get_numerical_csv_column(filename, 3);
gameplay_fromsync(:,4) = get_numerical_csv_column(filename, 4);
gameplay_fromsync(:,5) = get_numerical_csv_column(filename, 5);

% Extract sync time and sync index from csv.
% If more than one sync, get sync as specified in processed_data.scalars.
[processed_data.scalars.gameplay_sync_index, processed_data.scalars.gameplay_sync_epochtime]  = extract_csv_sync(filename, processed_data.scalars.which_gameplay_sync);

% Remove data from before sync.
% Subtract epoch time offset to get time = miliseconds from sync.
gameplay_fromsync = gameplay_fromsync(processed_data.scalars.gameplay_sync_index+1:end,:);
gameplay_fromsync(:,6) = gameplay_fromsync(:,6) - gameplay_fromsync(1,6);

% Remove duplicate entries with same timestamp.
gameplay_fromsync = remove_time_nodiffs(gameplay_fromsync, gameplay_fromsync(:,6));

% Remove data from timestamps after end of EEG data.
eeg_stamps = processed_data.eeg(1,:);
eeg_endstamp = eeg_stamps(end);
ind_timestamp_after_eeg_end = find(gameplay_fromsync(:,6) > eeg_endstamp);
if ~isempty(ind_timestamp_after_eeg_end)
    gameplay_fromsync = gameplay_fromsync(1:ind_timestamp_after_eeg_end,:);
end

fsr_table = table(gameplay_fromsync(:,6), gameplay_fromsync(:,1), gameplay_fromsync(:,2), gameplay_fromsync(:,3), gameplay_fromsync(:,4), gameplay_fromsync(:,5), 'VariableNames', {'timestamp_ms', 'A0','A1','A2','A3','A4'});

processed_data.fsr = fsr_table;

% 
% % Align data to master array
% l = 1;
% aligned_data(1).A0_fsr = 0;
% aligned_data(1).A1_fsr = 0;
% a1 = [];
% for k=1:length([aligned_data(:).timestamp_ms])
%     if (l > length(gameplay_fromsync(:,6)))
%         break;
%     end
%     if gameplay_fromsync(l,6) == aligned_data(k).timestamp_ms
%         aligned_data(k).A0_fsr = gameplay_fromsync(l,1);
%         a1 = [a1 gameplay_fromsync(l,2)];
%         aligned_data(k).A1_fsr = gameplay_fromsync(l,2);
%         aligned_data(k).A2_fsr = gameplay_fromsync(l,3);
%         aligned_data(k).A3_fsr = gameplay_fromsync(l,4);
%         aligned_data(k).A4_fsr = gameplay_fromsync(l,5);
%         l = l+1;
%     end
% end
% 
% %
% clearvars f gameplay_fromsync a1 gameplay_A0 gameplay_A1 gameplay_A2 gameplay_A3 gameplay_A4 gameplay_time_epoch old_path fsr_file fsr_name fsr_path ind_timestamp_after_eeg_end time_diffs time_nodiffs nodiffs_vec k l m zind a b l averagel;
