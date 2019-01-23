function the_fullpath = get_path_ui(the_trial_directory, the_pattern, the_descript, help_message, isfile)


the_fullpath = dir(fullfile(the_trial_directory, the_pattern));
if (~isempty(the_fullpath) && isfile)
    the_name = the_fullpath.name;
    the_path = the_fullpath.folder;
else
    if isfile
        msg = ['Unable to automatically locate ' the_descript '. Please find it manually.'];
        msg = [msg newline newline help_message];
        waitfor(warndlg(msg, 'Cannot Find Path'));
        the_split = strsplit(the_pattern, '.');
        the_ext = the_split(end);
        the_type = ['*.' char(the_ext)];
        [the_name, the_path] = uigetfile(the_type, ['Find ' the_descript]);
    else
        msg = ['Please select ' the_descript '.' newline newline help_message];
        waitfor(helpdlg(msg, 'Select Path'));
        the_name = '';
        the_path = uigetdir(the_trial_directory, ['Find ' the_descript]);
    end
    %isdlg = 'No';
    while the_path(1) == 0 && strcmp(questdlg(['No ' the_descript ' was selected. Do you want to keep looking for this yourself?'],'Cannot Find Path','Yes','No','Yes'),'Yes')
       if isfile
        [the_name, the_path] = uigetfile(file_type,['Find ' the_descript]);
       else
        the_path = uigetdir(the_trial_directory, ['Find ' the_descript]);
       end
    end
    if the_path(1) == 0
        waitfor(errordlg(['Aborting data processing: no valid ' the_descript ' found'], 'Path Not Available'));
        throw(MException('Custom:Custom',['Failure: unable to find valid ' the_descript '.']));
    end
end

if isfile
    the_fullpath = fullfile(the_path,the_name);
else
    the_fullpath = the_path;
end

end