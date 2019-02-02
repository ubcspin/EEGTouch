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
    microsecs = str2num(tag(cplace+7:cplace+12));
    dins = [dins microsecs + secs*1000000 + mins*60*1000000;];
end
fclose(fileID);
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
microsecs = str2num(tag(cplace+7:cplace+12));
which_din = 0;
if length(dins) > 1
%%take user input on which din
    while which_din < 1 || which_din > length(dins)
        prompt = {['DIN log has multiple DIN1s for this trial. Which DIN to use (between 1 and ' num2str(length(dins)) ' inclusive?) Check notes for this trial if unsure.']};
        title = 'Select DIN';
        dims = [1 35];
        definput =cellstr('1');
        answer = inputdlg(prompt,title,dims,definput);
        if ~isempty(answer)
                which_din = str2num(answer{1});
        end
        while (isempty(which_din) || which_din < 1 || which_din > length(dins) || which_din ~= floor(which_din) )&& ~strcmp(questdlg(['No valid DIN index entered. Please double check value and enter an integer between 1 and ' num2str(length(dins)) '. Do you want to try again?'],'Invalid DIN Index','Yes','No','Yes'),'Yes')
            waitfor(errordlg('No valid DIN index available. Data processing aborted.'));
            throw(MException('Custom:Custom','Failure: DIN index.'));
        end
    end
else
    which_din = 1;
end

din_time_ms = dins(which_din);
processed_data.scalars.din_time_ms  = din_time_ms;
eeg_start_time_ms = microsecs + secs*1000000 + mins*1000000*60;
processed_data.scalars.eeg_start_time_ms = eeg_start_time_ms;