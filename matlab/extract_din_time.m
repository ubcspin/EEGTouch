%extract din time offset from netstation-generated XML files
%highly specific to our extraction settings
%times saved to scalars.eeg_start_time_ms
%and scalars_din_time_ms

din_path = '';
%name of xml file with the din
din_file = dir(fullfile(trial_directory,'*mff','Events_DIN1.xml'));
if ~isempty(din_file)
    din_name = fullfile(din_file.folder,din_file.name);
else
    waitfor(warndlg('Unable to automatically locate Events DIN xml file for this trial. Please find it manually. The file is usually called Events_DIN1.xml and in a date-stamped folder ending with mff.'));
    [din_name,din_path] = uigetfile('*.xml','Find Events DIN1 xml file');
    isdlg = 'No';
    while (din_name(1) == 0) && strcmp(questdlg('No Events DIN 1 xml file was opened. Do you want to keep looking for this file yourself?',''),'Yes')
       [din_name,din_path] = uigetfile('*.xml','Find Events DIN1 xml file');
    end
    if din_name(1) == 0
        waitfor(errordlg('Aborting data processing: no valid DIN xml file'));
        throw(MException('Custom:Custom','Failure: unable to find valid DIN xml file'));
    end
end

info_path = '';
%name of xml file with the info
info_file = dir(fullfile(trial_directory,'*mff','info.xml'));
if ~isempty(info_file)
    info_name = fullfile(info_file.folder, info_file.name);
else
    waitfor(warndlg('Unable to automatically locate info xml file for this trial. Please find it manually. The file is usually called info.xml and in a date-stamped folder ending with mff.'));
    [info_name, info_path] = uigetfile('*.xml','Find info xml file');
    isdlg = 'No';
    while (info_name(1) == 0) && strcmp(questdlg('No info xml file was opened. Do you want to keep looking for this file yourself?',''),'Yes')
       [info_name,info_path] = uigetfile('*.xml','Find Events DIN1 xml file');
    end
    if info_name(1) == 0
        waitfor(errordlg('Aborting data processing: no valid info xml file'));
        throw(MException('Custom:Custom','Failure: unable to find valid info xml file'));
    end
end

if ~contains(din_name,pathsep)
    din_name= fullfile(din_path,din_name);
end

if ~contains(info_name,pathsep)
    info_name= fullfile(info_path,info_name);
end

f = waitbar(0,'Extracting din time','Name','Data Processing');

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
        if (isempty(which_din) || which_din < 1 || which_din > length(dins) || which_din ~= floor(which_din) )&& ~strcmp(questdlg(['No valid DIN index entered. Please double check value and enter an integer between 1 and ' num2str(length(dins)) '. Do you want to try again?']),'Yes');
            waitfor(errordlg('No valid DIN index available. Data processing aborted.'));
            throw(MException('Custom:Custom','Failure: DIN index.'));
        end
    end
else
    which_din = 1;
end
scalars.din_time_ms = dins(which_din);
scalars.eeg_start_time_ms = microsecs + secs*1000000 + mins*1000000*60;

close(f);
%%%
%clearvars f info_path din_path isdlg should_open din_name info_name has_time fileID din_imp info_imp tag cplace mins secs microsecs k dins which_din din_file info_file;