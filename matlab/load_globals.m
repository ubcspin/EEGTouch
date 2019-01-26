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
    processed_directory = get_path_ui(pwd, '', directory_type, directory_helpmessage,false);
end
[fid, errormsg] = fopen(fullfile(processed_directory,'not_a_real_file.txt'), 'a');
fclose(fid);
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
if ~exist('processed_directory','var')
    get_processed_directory;
end
if isfile(fullfile(processed_directory,'processed_data.mat'))
    t_processed_data = processed_data;
    t_fieldnames = fieldnames(t_processed_data);
    open(fullfile(processed_directory,'processed_data.mat'));
    for i = numel(t_fieldnames)
        if strcmp(t_fieldnames{i},'scalars');
            processed_data.(t_fieldnames{i}) = t_processed_data.(t_fieldnames{i});
        else
            t_scalar_fieldnames = fields(t_processed_data.scalars);
            for j = numel(t_scalar_fieldnames)
                processed_data.scalars.(t_scalar_fieldnames{i}) = t_processed_data.scalars.(t_struct_fieldnames{i});
            end
        end
    end
end

%% LOAD TRIAL NUMBER
if ~exist('trial_number', 'var') 
    if exist('processed_data','var') && any(ismember(fields(processed_data),{'scalars'})) && ~any(ismember(fields(processed_data.scalars),{'trial_number'}))
        trial_number = processed_data.scalars.trial_number;
    else
        prompt = {'Enter trial number:'};
        title = 'Trial number';
        dims = [1 50];
        % put thing anticipating here
        definput = {'0'};
        trial_response_cell = inputdlg(prompt,title,dims,definput);
        trial_number = trial_response_cell{1};
    end
end
processed_data.scalars.trial_number = trial_number{1};


