function labels = import_labels(label_dir)
    %% Initialize variables.
    filename = get_path_ui(label_dir, '*.csv', 'Labels CSV', 'It is the CSV file of all the labels for different scenes, a copy is kept on the Google Drive.', true, false);
    delimiter = ',';
    %% Format for each line of text:
    %   column1: categorical (%C)
    %	column2: text (%s)
    %   column3: categorical (%C)
    %	column4: categorical (%C)
    % For more information, see the TEXTSCAN documentation.
    formatSpec = '%C%s%C%C%[^\n\r]';

    %% Open the text file.
    fileID = fopen(filename,'r');

    %% Read columns of data according to the format.
    % This call is based on the structure of the file used to generate this
    % code. If an error occurs for a different file, try regenerating the code
    % from the Import Tool.
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string',  'ReturnOnError', false);

    %% Close the text file.
    fclose(fileID);

    %% Post processing for unimportable data.
    % No unimportable data rules were applied during the import, so no post
    % processing code is included. To generate code which works for
    % unimportable data, select unimportable cells in a file and regenerate the
    % script.

    %% Create output variable
    labels = table(dataArray{1:end-1}, 'VariableNames', {'scene','tag','stream','type'});
end

function scenes = set_scenes(labels)
    scene_names_raw = string(unique(labels.scene, 'stable'));
    scene_names_raw = scene_names_raw(2:end);

    scenes = [];

    for i = 1:length(scene_names_raw)
        this_scene = scene_names_raw(i);
        scenes(i).name = this_scene;
        indices = find(string(labels.scene) == this_scene);

        begin = find(string(labels.type(indices)) == "begin");
        if ~isempty(begin)
            for j = 1:length(begin)
                scenes(i).begin(j).stream = string(labels.stream(indices(begin(j))));
                scenes(i).begin(j).tag = labels.tag(indices(begin(j)));
            end
        end

        peak = find(string(labels.type(indices)) == "peak");
        if ~isempty(peak)
            for j = 1:length(peak)
                scenes(i).peak(j).stream = string(labels.stream(indices(peak(j))));
                scenes(i).peak(j).tag = labels.tag(indices(peak(j)));
            end
        end

        finish = find(string(labels.type(indices)) == "end");
        if ~isempty(finish)
            for j = 1:length(finish)
                scenes(i).finish(j).stream = string(labels.stream(indices(finish(j))));
                scenes(i).finish(j).tag = labels.tag(indices(finish(j)));
            end
        end
    end
end