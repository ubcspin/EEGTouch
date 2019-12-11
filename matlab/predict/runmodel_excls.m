function [model_results, yacc_rate] = runmodel_excls(collated_freq_table, table_with_exclusions)
    % TODO: confirm order of collated_freq_table and table_with_exclusions

    % number of trials
    num_indxs = length(collated_freq_table);

    model_results = cell(num_indxs,1);
    yacc_rate = zeros(num_indxs,1);

    for i = 1:num_indxs
        % trainedClassifier, validationAccuraty:
        % train a classifier on all trials except trial i
        % (to predict js_slopecat)
        % (this excludes js_slopecat, multicat and joystick)
        [model_results{i}.trainedClassifier, model_results{i}.validationAccuracy] = trainClassifier(table_with_exclusions{i});
        % yfit_excl: 
        % now use that trained model to predict js_slopecat from trial i
        model_results{i}.yfit_excl = model_results{i}.trainedClassifier.predictFcn(collated_freq_table{i}.freq_table);
        % yreal:
        % actual js_slopecat values from trial i
        model_results{i}.yreal = collated_freq_table{i}.freq_table.js_slopecat;
        % yacc:
        % logical vector, was the js_slopecat prediction from this sample accurate
        model_results{i}.yacc = model_results{i}.yfit_excl == model_results{i}.yreal;
        % yacc_rate:
        % rate of correct predictions
        model_results{i}.yacc_rate = sum(model_results{i}.yacc)/length(model_results{i}.yacc);
        % yperc = simple numeric vector of accuracy across trials
        yacc_rate(i) = model_results{i}.yacc_rate;
    end
end

%[trainedClassifier, validationAccuracy] = trainClassifier(T);
%yfit = trainedClassifier.predictFcn(T2);