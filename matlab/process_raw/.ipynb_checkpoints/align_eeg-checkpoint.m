function eeg_timeseries = align_eeg(local_paths, trial_data)
    %function aligned_ = remove_time_nodiffs(value_matrix, times)
    % get matlab EEG file - find in directory or from UI dialog.
    eeg_name = get_path_ui(local_paths.trial_directory, '*201*.mat', 'EEG Matlab data', 'The file is usually named with a date and time stamp with the extension .mat and in the main trial directory.',true,false);

    % load matlab EEG file
    load(eeg_name);

    % find name of eeg data variable
    % (the file has the eeg data in a matrix with an auto-generated name)
    % this find the data and puts it in a var called 'eeg_data'
    varnames = who('*mff*');
    if length(varnames) > 1
        eeg_data_raw = [];
        for i = 1:length(varnames)
           this_eeg = eval(varnames{i});
           eeg_data_raw = horzcat(eeg_data_raw, this_eeg); 
        end
    else
        eeg_data_raw = eval(varnames{1});
    end

    if exist('evt_DIN1','var')
        all_din_times = [evt_DIN1{2,:}];
        if length(all_din_times) > 1
            which_din = select_which_din(all_din_times, trial_data.scalars.trial_number);
            din_time = all_din_times(which_din);
        else
            din_time = all_din_times(1);
        end
    else
        waitfor(errordlg('No DIN1 signal in EEG file. Aborting EEG data processing.'));
        throw(MException('Custom:Custom' ,'No DIN1 signal in EEG file.'));
    end
    % crop eeg data to din sync 
    eeg_data = eeg_data_raw(:,din_time:end).';

    % add a row for millisecond timestamp to synced eeg data
%     stamps = ones(length(eeg_data),1);
%     stamps(1) = 0;
%     stamps = cumsum(stamps);

    stamps = (0:(length(eeg_data) - 1))';
    eeg_timeseries = table(stamps,eeg_data,'VariableNames',{'timestamp_ms','eeg'});
end

function which_din = select_which_din(all_din_times, trial_number)
    msg = [{['More than one DIN1 signal time found for trial ' char(trial_number) '. Please select the appropriate DIN to use.']} {''} {''} {''}];
    title = 'Select DIN';
    list = {};
    for i = 1:length(all_din_times)
        this_din = all_din_times(i);
        din_mins = floor(this_din/60000);
        din_secs = floor(rem(this_din,60000)/1000);
        din_ptsecs = rem(this_din,1000);
        offset_str = [num2str(din_mins) ' mins, ' num2str(din_secs) '.' num2str(din_ptsecs) ' secs from EEG start'];
        list{end+1} = [num2str(i) ': ' offset_str];
    end
    tf = false;
    while ~tf
        [indx,tf] = listdlg('PromptString',msg,'Name',title,'ListSize',[250,75],'SelectionMode','single','ListString',list);
        if ~tf
            if strcmp(questdlg('No DIN selected. Do you want to try again?','No DIN selected','Yes','No','Yes'),'No')
                waitfor(errordlg('Aborting data processing: refusal to choose a DIN when more than one exists.', 'Did Not Choose DIN'));
                throw(MException('Custom:Custom','Failure: unable to choose a DIN'));
            end
        end
    end
    which_din = indx;
end