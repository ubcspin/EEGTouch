function [collapsed_table, table_with_exclusions] = test_collapsetable(collated_freq_table)
    %table_indxs = find(arrayfun(@(x) ~isempty(x{1}),collated_freq_table));
    %num_indxs = length(table_indxs);
    %collapsed_celltab = cell(num_indxs,1);
    %num_tri = 23
    cell_just_freq_tables = cell(length(collated_freq_table),1);
    for i = 1:length(collated_freq_table)
        cell_just_freq_tables{i} = collated_freq_table{i}.freq_table;
    end
    collapsed_table = vertcat(cell_just_freq_tables{1:end});

    table_with_exclusions = cell(length(collated_freq_table),1);
    for i = 1:length(collated_freq_table)
        collapsed_table_excluding_one_trial = cell_just_freq_tables;
        collapsed_table_excluding_one_trial{i} = [];
        table_with_exclusions{i} = balance_freq_table(vertcat(collapsed_table_excluding_one_trial{1:length(collated_freq_table)}));
    end
end