load_globals;

% get matlab EEG file - find in directory or from UI dialog.
eeg_name = get_path_ui(trial_directory, '*201*.mat', 'EEG Matlab data', 'The file is usually named with a date and time stamp with the extension .mat and in the main trial directory.',true);

% load matlab EEG file
load(eeg_name);

% find name of eeg data variable
% (the file has the eeg data in a matrix with an auto-generated name)
% this find the data and puts it in a var called 'eeg_data'
varnames = who('*mff*');
if length(varnames) > 1
%         msg = [{['More than one matrix in MAT file. Please select which matrix to use.' ]} {''} {''} {''}];
%         title = ['Select Matrix'];
%         list = {};
%         for i = 1:length(varnames)
%             eva = eval(varnames{i});
%             list{end+1} = ['Matrix ' num2str(i) ': ' num2str(floor(length(eva)/60000)) ' min, ' num2str(floor(rem(length(eva),60000)/1000)) ' sec, ' num2str(rem(length(eva),1000)) ' millisec'];
%         end
%         tf = false;
%         while ~tf
%             [indx,tf] = listdlg('PromptString',msg,'Name',title,'ListSize',[250,75],'SelectionMode','single','ListString',list);
%             if ~tf
%                 if strcmp(questdlg(['No matrix selected. Do you want to try again?'],['No matrix selected'],'Yes','No','Yes'),'No')
%                     waitfor(errordlg(['Aborting data processing: refusal to choose a matrix when more than one exists.'], 'Did Not Choose matrix'));
%                     throw(MException('Custom:Custom',['Failure: unable to choose a matrix']));
%                 end
%             end
%         end
%     which_mat = indx;
% else
%     which_mat = 1;
    eeg_data_raw = [];
    for i = 1:length(varnames)
       this_eeg = eval(varnames{i});
       eeg_data_raw = horzcat(eeg_data_raw, this_eeg); 
    end
else
    eeg_data_raw = eval(varnames{1});
end

% crop eeg data to din sync 
% TODO: check if there is a din extract first? 
% or not just use the one in the matfile!!!
%extract_din_time;

eeg_data = eeg_data_raw(:,(processed_data.scalars.din_time_ms-processed_data.scalars.eeg_start_time_ms):end).';

% add a row for millisecond timestamp to synced eeg data
stamps = ones(length(eeg_data),1);
stamps(1) = 0;
stamps = cumsum(stamps);
eeg_table = table(stamps,eeg_data,'VariableNames',{'timestamp_ms','eeg'});
processed_data.eeg = eeg_table;

clearvars -regexp .+mff*
clearvars -regexp ^evt.+
clearvars eva i indx list msg eeg_data eeg_data_raw eeg_name eeg_table EEGSamplingRate evt_DIN1 Impedances_EEG_0 stamps varnames