function [Mdl, err, params, best] = fit_random_forest_tuning(X, y, categorical_predictors, minleaves, maxNumSplits, numTrees)
    Mdl = cell(numel(maxNumSplits),numel(minleaves));
    
    for k = 1:numel(minleaves);
        for j = 1:numel(maxNumSplits);
            fprintf('fitting random forest for %d min leaves and %d max splits... \n', minleaves(k), maxNumSplits(j))
            t = templateTree('MaxNumSplits',maxNumSplits(j), 'minleaf', minleaves(k), 'Surrogate','on');
            Mdl{j,k} = fitensemble(X,y,'bag',numTrees,t,'CategoricalPredictors', categorical_predictors,'Type','classification','KFold', 5);
        end;
    end;
    
    kflAll = @(x)kfoldLoss(x,'Mode','cumulative');
    errorCell = cellfun(kflAll,Mdl,'Uniform',false);
    err = reshape(cell2mat(errorCell),[numTrees numel(maxNumSplits) numel(minleaves)]);
    
    [minErr,minErrIdxLin] = min(err(:));
    [idxNumTrees,idxMNS,idxMinLeaf] = ind2sub(size(err),minErrIdxLin);
    params = struct('num_tree', idxNumTrees, ...
                    'max_num_splits', maxNumSplits(idxMNS), ...
                    'min_leaves', minleaves(idxMinLeaf))

    best = Mdl(idxMNS, idxMinLeaf);
    best = best{1};
    ypred = kfoldPredict(best);
    [C, order] = confusionmat(best.Y,ypred);
    h = heatmap(int8(order), int8(order), C/sum(sum(C)));
    caxis([0, 0.6])
    h.Title = sprintf('Overall accuracy %0.2f', trace(C/sum(sum(C))));
end