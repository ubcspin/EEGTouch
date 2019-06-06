function trial_data = load_trial_data(local_paths,trial_arg_data)
%LOAD_TRIAL_DATA 
    %trial_data = struct;
    %TODO: improve these names
    %if isfile(fullfile(local_paths.processed_directory,processed_data_filename))
    existing_data_path = get_path_ui(local_paths.processed_directory, '*data*.mat', 'existing processed trial data file', 'This is only necessary if you want to add to an existing processed trial data file for this trial. If so, this file is usually called processed_data.mat or pX_trial_data.mat',true,true);
    if strlength(existing_data_path) > 0
        load(existing_data_path,'*data');
        varnames = [who('*trial_data'); who('processed_data')]; 
        trial_data = eval(varnames{1});
        arg_fieldnames = fieldnames(trial_arg_data);
        if ~isempty(arg_fieldnames)
            for i = 1:numel(arg_fieldnames)
                if ~strcmp(arg_fieldnames{i},'scalars')
                    trial_data.(arg_fieldnames{i}) = trial_arg_data.(arg_fieldnames{i});
                else
                    arg_scalar_fieldnames = fields(trial_arg_data.scalars);
                    for j = 1:numel(arg_scalar_fieldnames)
                        trial_data.scalars.(arg_scalar_fieldnames{i}) = trial_arg_data.scalars.(arg_scalar_fieldnames{i});
                    end
                end
            end
        end
    else
        trial_data = trial_arg_data;
    end
    
    %%trial number
    %% LOAD TRIAL NUMBER
    %if ~exist('trial_number', 'var') || isempty(trial_number) 
    %if exist('processed_data','var') && any(ismember(fields(trial_data),{'scalars'})) && any(ismember(fields(trial_data.scalars),{'trial_number'}))
    if ~(exist('trial_data','var') && any(ismember(fields(trial_data),{'scalars'})) && any(ismember(fields(trial_data.scalars),{'trial_number'})))
        trial_data.scalars.trial_number = get_trial_number(false);
    end
end

