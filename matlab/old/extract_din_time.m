%extract din time offset from netstation-generated XML files
%highly specific to our extraction settings
%times saved to processed_data.scalars.eeg_start_time_ms
%and processed_data.scalars.din_time_ms

% If no trial directory variable, try current directory.
load_globals;

% Get DIN1 xml and info xml - find in directory or from UI dialog.
din_name = get_path_ui(trial_directory, fullfile('*mff','Events_DIN1.xml'), 'DIN1 xml file', 'The file is usually called Events_DIN1.xml and in a date-stamped folder ending with mff inside the main trial directory.',true);
info_name = get_path_ui(trial_directory, fullfile('*mff','info.xml'), 'info xml file', 'The file is usually called info.xml and in a date-stamped folder ending with mff inside the main trial directory.',true);

fileID = fopen(din_name,'r');
din_imp = textscan(fileID,'%s');
din_imp = din_imp{1};
has_time = find(contains(din_imp,"Time>"));
dins = []; %in microseconds
for k = 1:length(has_time)
    tag = din_imp(has_time(k));
    tag = tag{1};
    cplace = strfind(tag,':');
    cplace = cplace(1);
    mins = str2num(tag(cplace+1:cplace+2));
    secs = str2num(tag(cplace+4:cplace+5));
    subsecs = str2num(tag(cplace+7:cplace+12));
    dins = [dins round(subsecs/1000) + secs*1000 + mins*60*1000;];
end
status = fclose(fileID);
fileID = fopen(info_name,'r');
info_imp = textscan(fileID,'%s');
info_imp = info_imp{1};
has_time = find(contains(info_imp,"Time>"));
tag = info_imp(has_time);
tag = tag{1};
cplace = strfind(tag,':');
cplace = cplace(1);
mins = str2num(tag(cplace+1:cplace+2));
secs = str2num(tag(cplace+4:cplace+5));
subsecs = str2num(tag(cplace+7:cplace+12));
eeg_start_time_ms = round(subsecs/1000) + secs*1000 + mins*1000*60;
processed_data.scalars.eeg_start_time_ms = eeg_start_time_ms;

which_din = 0;

if length(dins) > 1
    msg = [{['More than one DIN1 signal time found for trial ' trial_number '. Please select the appropriate DIN to use.']} {''} {''} {''}];
        title = ['Select DIN'];
        list = {};
        for i = 1:length(dins)
            offsetd = dins(i) - eeg_start_time_ms;
            offsetd_mins = floor(offsetd/60000);
            offsetd_secs = floor(rem(offsetd,60000)/1000);
            offsetd_ptsecs = rem(offsetd,1000);
            offset_str = [num2str(offsetd_mins) ' mins, ' num2str(offsetd_secs) '.' num2str(offsetd_ptsecs) ' secs from EEG start'];
            list{end+1} = [num2str(i) ': ' offset_str];
        end
        tf = false;
        while ~tf
            [indx,tf] = listdlg('PromptString',msg,'Name',title,'ListSize',[250,75],'SelectionMode','single','ListString',list);
            if ~tf
                if strcmp(questdlg(['No DIN selected. Do you want to try again?'],['No DIN selected'],'Yes','No','Yes'),'No')
                    waitfor(errordlg(['Aborting data processing: refusal to choose a DIN when more than one exists.'], 'Did Not Choose DIN'));
                    throw(MException('Custom:Custom',['Failure: unable to choose a DIN']));
                end
            end
        end
which_din = indx;
else
    which_din = 1;
end

din_time_ms = dins(which_din);
processed_data.scalars.din_time_ms  = din_time_ms;


clearvars answer status cplace definput dims din_imp din_name din_time_ms dins eeg_start_time_ms fileID has_time info_imp info_name k millisecs mins prompt secs tag title which_din i indx list msg offset_str offsetd offsetd_mins offsetd_secs offsetd_ptsecs subsecs tf 