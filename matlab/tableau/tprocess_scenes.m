load_all_processed;

all_scenes = table('Size', [0 5], 'VariableTypes', {'string', 'double', 'double', 'double', 'double'}, ... 
    'VariableNames', {'scene', 'len_ms', 'start_ms', 'end_ms', 'pnum'});
all_deaths = cell(0,11);

for i = 1:size(all_data,1)
    pfile = all_data{i,1};
    
    if ~isempty(pfile)
        fprintf('Extracting scene data from participant %d...\n', i);
        scene_data = extract_scenes(pfile.processed_data);
        
        scene_data_len = size(scene_data, 1);
        
        % Process scene information into viz-ready format, and append
        % participant number to rightmost column.
        
        for j = 1:scene_data_len
            if scene_data{j,10}==1 % if this is begin
                for k = j+1:scene_data_len
                    % if this is next begin, or end of file, save scene len
                    if scene_data{k,10}==1
                        current_scene.scene = scene_data{k-1,1};
                        current_scene.len_ms = scene_data{k-1,9} - scene_data{j,9};
                        current_scene.start_ms = scene_data{j,9};
                        current_scene.end_ms = scene_data{k-1,9};
                        current_scene.pnum = i;
                        all_scenes = [all_scenes; struct2table(current_scene)];
                        break
                    end 
                    if k==scene_data_len
                        current_scene.scene = scene_data{k,1};
                        current_scene.len_ms = scene_data{k,9} - scene_data{j,9};
                        current_scene.start_ms = scene_data{j,9};
                        current_scene.end_ms = scene_data{k,9};
                        current_scene.pnum = i;
                        all_scenes = [all_scenes; struct2table(current_scene)];
                        break
                    end
                    
                end
            end
        end
        
        % Filter out all deaths from scene data, and append participant
        % number to rightmost column. 
        deaths = scene_data(([scene_data{:,6}]==1), :);
        deaths = [deaths repmat({i}, size(deaths,1), 1)];
        all_deaths = vertcat(all_deaths, deaths);
    end
end 

writetable(all_scenes, './tableau/scenes.csv');
writetable(cell2table(all_deaths, 'VariableNames', {'scene', 'event_type', 'begin', 'peak', 'ending', 'death', 'event_label', 'event_index', 'timestamp_ms', 'is_begin', 'pnum'}), './tableau/deaths.csv');

clearvars deaths i j k pfile char scene_data_len current_scene