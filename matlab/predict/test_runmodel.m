table_indxs = find(arrayfun(@(x) ~isempty(x{1}),coll_tables));
num_indxs = length(table_indxs);
num_tri = 23;
yfit1 = cell(num_tri,1);
yreal1 = cell(num_tri,1);
yacc1 = cell(num_tri,1);
yperc1 = zeros(num_tri,1);
for i = 1:num_indxs
    yfit1{table_indxs(i)} = trainedModel1.predictFcn(coll_tables{table_indxs(i)}.freq_table);
    yreal1{table_indxs(i)} = coll_tables{table_indxs(i)}.freq_table.ft_slopecat;
    yacc1{table_indxs(i)} = yfit1{table_indxs(i)} == yreal1{table_indxs(i)};
    yperc1(table_indxs(i)) = sum(yacc1{table_indxs(i)})/length(yacc1{table_indxs(i)});
end

%yfit = trainedModel.predictFcn(coll_tables{2}.freq_table);