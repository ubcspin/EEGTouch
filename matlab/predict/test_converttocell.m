function [cells, joystick, js_slopecat, js_multicat] = convert_to_cell(freq_table)
    %table_10 = collated_freq_table{1}.unbalanced_freq_table;
    freq_table.events_game = grp2idx(categorical(freq_table.events_game));
    .events_sound = grp2idx(categorical(table_10.events_sound));
    table_10.events_character = grp2idx(categorical(table_10.events_character));
    table_10.inteview = grp2idx(categorical(table_10.inteview));

    % js_slopecat10 = table_10.js_slopecat';
    % js_slopecat_mult10 = table_10.js_slopecat_mult';
    js_slopecat10 =  mat2cell(table_10.js_slopecat(:), ones(length(table_10.js_slopecat), 1))';
    js_slopecat_mult10 =  mat2cell(table_10.js_slopecat_mult(:), ones(length(table_10.js_slopecat_mult), 1))';
    joystick10 =  mat2cell(table_10.joystick(:), ones(length(table_10.joystick), 1))';

    table_10 = removevars(table_10, {'js_slopecat', 'js_slopecat_mult', 'joystick','events_game','events_sound','events_character','inteview','calibrated_words'});
    %table_10 = removevars(table_10, {'js_slopecat', 'js_slopecat_mult', 'joystick','events_game','events_sound','events_character','inteview'});
    cells_10 = mat2cell(table_10{:,:}, ones(1,size(table_10{:,:},1)))';
    cells_10 = cellfun(@transpose,cells_10,'UniformOutput',false);
end
