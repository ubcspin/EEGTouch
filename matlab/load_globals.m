%% LOAD TRIAL DIRECTORY
if ~exist('trial_directory', 'var')
        directory_type = 'trial directory';
        directory_helpmessage = 'This is the directory that contains one trial worth of raw data you downloaded from the server.';
        trial_directory = get_path_ui(pwd, '', directory_type, directory_helpmessage,false);
end

%% LOAD PROCESSED DIRECTORY
if ~exist('processed_directory', 'var')
    directory_type = 'processed data directory';
    directory_helpmessage = 'This is the directory where processed data from this trial will be saved to.';
    processed_directory = get_path_ui(trial_directory, '', directory_type, directory_helpmessage,false);
end
[fid, errormsg] = fopen(fullfile(processed_directory,'not_a_real_file.txt'), 'a');
errormsg_2 = fclose(fid);
delete(fullfile(processed_directory,'not_a_real_file.txt'));
while strcmp(errormsg,'Permission denied')
    msg = 'Cannot write to selected directory.';
    msg = [msg newline newline 'Please select different directory for saving processed data.'];
    waitfor(warndlg(msg));
    processed_directory = get_path_ui(pwd, '', 'processed data directory', 'This is the directory where processed data from this trial will be saved to.', false);
    [fid, errormsg] = fopen(fullfile(processed_directory,'not_a_real_file.txt'), 'a');
    fclose(fid);
    delete(fullfile(processed_directory,'not_a_real_file.txt'));
end

%% LOAD PROCESSED DATA
if ~exist('processed_data','var')
    processed_data = struct;
end
if isfile(fullfile(processed_directory,'processed_data.mat'))
    t_processed_data = processed_data;
    t_fieldnames = fieldnames(t_processed_data);
    load(fullfile(processed_directory,'processed_data.mat'));
    if ~isempty(t_fieldnames)
        for i = 1:numel(t_fieldnames)
            if strcmp(t_fieldnames{i},'scalars')
                processed_data.(t_fieldnames{i}) = t_processed_data.(t_fieldnames{i});
            else
                t_scalar_fieldnames = fields(t_processed_data.scalars);
                for j = 1:numel(t_scalar_fieldnames)
                    processed_data.scalars.(t_scalar_fieldnames{i}) = t_processed_data.scalars.(t_scalar_fieldnames{i});
                end
            end
        end
    end
end

%% LOAD TRIAL NUMBER
if ~exist('trial_number', 'var') || isempty(trial_number) 
    if exist('processed_data','var') && any(ismember(fields(processed_data),{'scalars'})) && any(ismember(fields(processed_data.scalars),{'trial_number'}))
        trial_number = processed_data.scalars.trial_number;
    else
        trial_response_cell= {};
        trial_number = [];
        while isempty(trial_response_cell) || isempty(trial_number)
            prompt = {'Enter trial number:'};
            title = 'Trial number';
            dims = [1 50];
            definput = {''};
            trial_response_cell = inputdlg(prompt,title,dims,definput);
            if ~isempty(trial_response_cell)
                trial_number = trial_response_cell{1};
            end
            if (isempty(trial_response_cell) || isempty(trial_number)) && ~strcmp(questdlg('No trial number entered. Do you want to try entering a trial number again?','No Trial Number','Yes','No','Yes'),'Yes') 
                waitfor(errordlg('Failure: no trial number entered.','No Trial Number'));
                throw(MException('Custom:Custom' ,'Failure: no trial number.'));
            end
        end
    end
end
processed_data.scalars.trial_number = trial_number;

clearvars definput dims directory_helpmessage directory_type errormsg fid prompt t_fieldnames t_processed_data title trial_response_cell errormsg_2 filename i j t_scalar_fieldnames

