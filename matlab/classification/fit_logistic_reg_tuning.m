function [Mdl, err, params, best] = fit_logistic_reg_tuning(X, y, categorical_predictors, lambdas)
    X(isnan(X)) = 0;
    for i = 1:numel(categorical_predictors)
        X = [X dummyvar(X(:, categorical_predictors(i)))];
    end
    X(:, categorical_predictors) = [];
    
    Mdl = cell(numel(lambdas));
    for j = 1:numel(lambdas);
        fprintf('fitting logistic_regression for lambda = %d \n', lambdas(j))
        t = templateLinear('Learner', 'logistic', 'Regularization', 'lasso', 'Lambda', lambdas(j));
%         t = templateSVM('Standardize',true,'KernelFunction','gaussian')
        Mdl{j} = fitcecoc(X, y, 'Learners', t, 'KFold', 5);
    end;
    
    kflAll = @(x)kfoldLoss(x);
    errorCell = cellfun(kflAll,Mdl,'Uniform',false);
    err = cell2mat(errorCell);
    
    [minErr,minErrIdxLin] = min(err(:));
    params = struct('lambda', lambdas(minErrIdxLin))

    best = Mdl(minErrIdxLin);
    best = best{1};
    ypred = kfoldPredict(best);
    [C, order] = confusionmat(best.Y,ypred);
    h = heatmap(int8(order), int8(order), C/sum(sum(C)));
    caxis([0, 0.6])
    h.Title = sprintf('Overall accuracy %0.2f', trace(C/sum(sum(C))));
end