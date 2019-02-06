% Import FSR data and align to EEG.

% Ensure trial directory, processed directory, trial data, are all loaded.
load_globals;

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
syncs = extract_csv_sync(fsr_file);

% If more than one sync, get sync as specified in processed_data.scalars.
[~, more_syncs] = size(syncs);

if more_syncs > 1
has_gameplaysync = false;
t_fieldnames = fieldnames(processed_data.scalars);
if ~isempty(t_fieldnames)
    for i = 1:numel(t_fieldnames)
        if strcmp(t_fieldnames{i},'which_gameplay_sync')
            has_gameplaysync = true;
        end
    end
end

if (~has_gameplaysync)
    NO_TRIAL_HAS_MORE_SYNC_BUTTON_PRESSES_THAN = 20;
    if strcmp(questdlg('Processed data does not yet indicate which sync button press to use. How many times was the sync button pressed in this trial after the last time the server was started?','Unsure Which Sync','1','>1 or Not Sure','>1 or Not Sure'),'>1 or Not Sure')
       waitfor(warndlg('If necessary, rewatch the trial video or review trial notes to determine which sync button press to use.','Need To Know Which Sync'));
       which_sync_response = [];
       which_sync_num = [];
       while (isempty(which_sync_response) || isempty(which_sync_num) || which_sync_num < 1 || which_sync_num > NO_TRIAL_HAS_MORE_SYNC_BUTTON_PRESSES_THAN)
            prompt = {'Which sync button press should be used?'};
            title = 'Enter sync button press';
            dims = [1 50];
            definput = {''};
            which_sync_response_cell = inputdlg(prompt,title,dims,definput);
            which_sync_response = which_sync_response_cell{1};
            if ~isempty(which_sync_response)
                which_sync_num = str2num(which_sync_response);
            end
            if (isempty(which_sync_response) || isempty(which_sync_num) || which_sync_num < 1 || which_sync_num > NO_TRIAL_HAS_MORE_SYNC_BUTTON_PRESSES_THAN) && ~strcmp(questdlg(['Invalid sync number entered. Please enter a number between 1 and 20.' newline 'Do you want to try again?'],'Invalid Sync Number','Yes','No','Yes'),'Yes')
                throw(MException('Custom:Custom' ,'Failed to align FSR data: cannot determine which sync button press to use.'));
            end
       end
       processed_data.scalars.which_gameplay_sync = which_sync_num;
    else
       processed_data.scalars.which_gameplay_sync = 1;
    end
end
else
processed_data.scalars.which_gameplay_sync = 1;
end

if processed_data.scalars.which_gameplay_sync > 1
    sync_pair = syncs(processed_data.scalars.which_gameplay_sync);
else
    sync_pair = syncs;
end
processed_data.scalars.gameplay_sync_index = sync_pair(1);
processed_data.scalars.gameplay_sync_epochtime = sync_pair(2);

% Remove data from before sync.
% Subtract epoch time offset to get time = miliseconds from sync.
gameplay_fromsync = gameplay_fromsync(processed_data.scalars.gameplay_sync_index+1:end,:);
gameplay_fromsync(:,6) = gameplay_fromsync(:,6) - gameplay_fromsync(1,6);

% Remove duplicate entries with same timestamp.
gameplay_fromsync = remove_time_nodiffs(gameplay_fromsync, gameplay_fromsync(:,6));

% Remove data from timestamps after end of EEG data.
eeg_endstamp = processed_data.eeg.timestamp_ms(end);
ind_timestamp_after_eeg_end = find(gameplay_fromsync(:,6) > eeg_endstamp);
if ~isempty(ind_timestamp_after_eeg_end)
    gameplay_fromsync = gameplay_fromsync(1:ind_timestamp_after_eeg_end,:);
end

fsr_table = table(gameplay_fromsync(:,6), gameplay_fromsync(:,1), gameplay_fromsync(:,2), gameplay_fromsync(:,3), gameplay_fromsync(:,4), gameplay_fromsync(:,5), 'VariableNames', {'timestamp_ms', 'A0','A1','A2','A3','A4'});

processed_data.fsr = fsr_table;

clearvars A0_raw eeg_endstamp filename fsr_file fsr_table gameplay_fromsync has_gameplaysync i ind_timestamp_after_eeg_end more_syncs sync_pair syncs t_fieldnames