table_indxs = find(arrayfun(@(x) ~isempty(x{1}),coll_tables));
num_indxs = length(table_indxs);
collapsed_celltab = cell(num_indxs,1);
num_tri = 23;
for i = 1:num_indxs
    collapsed_celltab{i} = coll_tables{table_indxs(i)}.freq_table;
end

one_big_table = vertcat(collapsed_celltab{1:num_indxs});

big_tables = cell(num_tri,1);
for i = 1:num_indxs
    collapsed_celltab_excl = collapsed_celltab;
    collapsed_celltab_excl{i} = [];
    big_tables{table_indxs(i)} = balance_freq_table(vertcat(collapsed_celltab_excl{1:num_indxs}));
end

clearvars table_indxs num_indxs collapsed_celltab