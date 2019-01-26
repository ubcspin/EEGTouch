if ~exist('processed_data','var')
    processed_data = struct;
end
if ~exist('processed_directory','var')
    get_processed_directory;
end
if isfile(fullfile(processed_directory,'processed_data.mat'),)
    t_processed_data = processed_data;
    t_fieldnames = fieldnames(t_processed_data);
    open(fullfile(processed_directory,'processed_data.mat'));
    for i = numel(t_fieldnames)
        if t_fieldnames{i} ~= 'scalars';
            processed_data.(t_fieldnames{i}) = t_processed_data.(t_fieldnames{i});
        else
            t_struct_fieldnames = t_fieldnames(t_processed_data.scalars);
            for j = numel(t_struct_fieldnames)
                processed_data.(t_struct_fieldnames{i}) = t_processed_data.(t_struct_fieldnames{i});
            end
        end
    end
    processed_data = [the_processed_data processed_data];
end