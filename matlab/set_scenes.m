scene_names_raw = string(unique(labels.scene));
scene_names_vars =  arrayfun(@(c) lower(c{1}(c{1} ~= ' ')), string(unique(labels.scene)),'UniformOutput',false);

scenes = table;

for i = 1:length(scene_names)
    this_scene = scene_names(i);
    scenes = [scenes,table(struct,'VariableNames',{scene_names_vars(i)})];
    indices = find(labels.scene == scene_names_raw(i));
    
end
