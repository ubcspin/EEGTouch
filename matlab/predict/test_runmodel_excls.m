table_indxs = find(arrayfun(@(x) ~isempty(x{1}),coll_tables));
num_indxs = length(table_indxs);
num_tri = 23;

model_results = cell(num_tri);
yperc = zeros(num_tri,1);
for i = 1:num_indxs
    [model_results{table_indxs(i)}.trainedClassifier, model_results{table_indxs(i)}.validationAccuracy] = trainClassifier(big_tables{table_indxs(i)});
    model_results{table_indxs(i)}.yfit_excl = model_results{table_indxs(i)}.trainedClassifier.predictFcn(coll_tables{table_indxs(i)}.freq_table);
    model_results{table_indxs(i)}.yreal = coll_tables{table_indxs(i)}.freq_table.ft_slopecat;
    model_results{table_indxs(i)}.yacc = model_results{table_indxs(i)}.yfit_excl == model_results{table_indxs(i)}.yreal;
    model_results{table_indxs(i)}.yperc = sum(model_results{table_indxs(i)}.yacc)/length(model_results{table_indxs(i)}.yacc);
    yperc(table_indxs(i)) = model_results{table_indxs(i)}.yperc;
end
%[trainedClassifier, validationAccuracy] = trainClassifier(T);
%yfit = trainedClassifier.predictFcn(T2);