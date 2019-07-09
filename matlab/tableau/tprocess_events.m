%% PROCESSES ALL EVENT DATA INTO TABLEAU-READY CSV FILES

load_all_processed;

game = table('Size', [0 3], 'VariableTypes', {'double', 'string', 'double'}, 'VariableNames', {'timestamp_ms', 'label', 'pnum'});
char = table('Size', [0 3], 'VariableTypes', {'double', 'string', 'double'}, 'VariableNames', {'timestamp_ms', 'label', 'pnum'});
sound = table('Size', [0 3], 'VariableTypes', {'double', 'string', 'double'}, 'VariableNames', {'timestamp_ms', 'label', 'pnum'});

for i = 1:size(all_data,1)
    pfile = all_data{i,1};
    
    if ~isempty(pfile)
        fprintf('Processing event data from participant %d...\n', i);
        
        g_rows = size(pfile.processed_data.events.game, 1);
        c_rows = size(pfile.processed_data.events.character, 1);
        s_rows = size(pfile.processed_data.events.sound, 1);

        pfile.processed_data.events.game.pnum = ones(g_rows, 1) * i;
        pfile.processed_data.events.character.pnum = ones(c_rows, 1) * i;
        pfile.processed_data.events.sound.pnum = ones(s_rows, 1) * i;

        game = vertcat(game, pfile.processed_data.events.game);
        char = vertcat(char, pfile.processed_data.events.character);
        sound = vertcat(sound, pfile.processed_data.events.sound);
    end 
end

writetable(game, './tableau/events_game.csv')
writetable(char, './tableau/events_char.csv')
writetable(sound, './tableau/events_sound.csv')

clearvars c_rows g_rows s_rows i pfile char game sound
