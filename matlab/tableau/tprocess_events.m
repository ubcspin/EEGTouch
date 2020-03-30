%% PROCESSES ALL EVENT DATA INTO TABLEAU-READY CSV FILES

load_all_processed;

game = table('Size', [0 3], 'VariableTypes', {'double', 'string', 'double'}, 'VariableNames', {'timestamp_ms', 'label', 'pnum'});
char = table('Size', [0 3], 'VariableTypes', {'double', 'string', 'double'}, 'VariableNames', {'timestamp_ms', 'label', 'pnum'});
sound = table('Size', [0 3], 'VariableTypes', {'double', 'string', 'double'}, 'VariableNames', {'timestamp_ms', 'label', 'pnum'});

for i = 1:size(all_data,1)
    pfile = all_data{i,1};
    
    if ~isempty(pfile)
        fprintf('Processing event data from participant %d...\n', i);
        
        g_rows = size(pfile.events.game_controlled_visual, 1);
        c_rows = size(pfile.events.player_controlled, 1);
        s_rows = size(pfile.events.game_controlled_sound, 1);

        pfile.events.game_controlled_visual.pnum = ones(g_rows, 1) * i;
        pfile.events.player_controlled.pnum = ones(c_rows, 1) * i;
        pfile.events.game_controlled_sound.pnum = ones(s_rows, 1) * i;

        game = vertcat(game, pfile.events.game_controlled_visual);
        char = vertcat(char, pfile.events.player_controlled);
        sound = vertcat(sound, pfile.events.game_controlled_sound);
    end 
end

writetable(game, './tableau/events_game.csv')
writetable(char, './tableau/events_char.csv')
writetable(sound, './tableau/events_sound.csv')

clearvars c_rows g_rows s_rows i pfile