function the_fullpath = get_path_ui(the_trial_directory, the_pattern, the_descript, help_message, isfile)

the_fullpath = dir(fullfile(the_trial_directory, the_pattern));
the_split = strsplit(the_pattern, '.');
the_ext = the_split(end);
the_type = fullfile(the_trial_directory,['*.' char(the_ext)]);
if ~strcmp(the_pattern,'') && ~isempty(the_fullpath) %if a pattern is given, and it's matched
    [fp_size, ~] = size(the_fullpath);
    if fp_size > 1 %&& ~empty(the_pattern)
        if isfile
            file_or_folder = 'file';
        else
            file_or_folder = 'folder';
        end
        msg = [{['More than one ' file_or_folder ' matches the pattern ' the_pattern '. Please select the appropriate ' the_descript ' to use.']} {''} {help_message} {''} {''} {''} {''}];
        title = ['Select ' file_or_folder];
        list = {};
        for i = 1:fp_size
            list{end+1} = the_fullpath(i).name;
        end
        tf = false;
        while ~tf
            [indx,tf] = listdlg('PromptString',msg,'Name',title,'ListSize',[200,100],'SelectionMode','single','ListString',list);
            if ~tf
                if strcmp(questdlg(['No ' the_descript ' selected. Do you want to try again?'],['No ' the_descript ' selected'],'Yes','No','Yes'),'No')
                    waitfor(errordlg(['Aborting data processing: refusal to choose a ' the_descript ' when more than one exists.'], 'Did Not Choose'));
                    throw(MException('Custom:Custom',['Failure: unable to choose a ' the_descript '.']));
                end
            end
        end
        the_name = the_fullpath(indx).name;
        the_path = the_fullpath(indx).folder;
    else
        the_name = the_fullpath.name;
        the_path = the_fullpath.folder;
    end
else
    if isfile
        msg = ['Unable to automatically locate ' the_descript '. Please find it manually.'];
        msg = [msg newline newline help_message];
        waitfor(warndlg(msg, 'Cannot Find Path'));
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
        [the_name, the_path] = uigetfile(the_type,['Find ' the_descript]);
       else
        the_path = uigetdir(the_trial_directory, ['Find ' the_descript]);
       end
    end
    if the_path(1) == 0
        waitfor(errordlg(['Aborting data processing: no valid ' the_descript ' found'], 'Path Not Available'));
        throw(MException('Custom:Custom',['Failure: unable to find valid ' the_descript '.']));
    end
end
the_fullpath = fullfile(the_path,the_name);
end