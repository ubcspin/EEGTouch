scene_names_raw = string(unique(labels.scene, 'stable'));
scene_names_vars =  arrayfun(@(c) lower(c{1}(c{1} ~= ' ')), string(unique(labels.scene, 'stable')),'UniformOutput',false);

scenes = [];

for i = 1:length(scene_names_raw)
    this_scene = scene_names_raw(i);
    scenes(i).name = scene_names_raw(i);
    indices = find(string(labels.scene) == scene_names_raw(i));
    
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