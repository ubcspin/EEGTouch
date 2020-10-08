
function [window_score_table] = feeltrace_word_eval_window(result, f)
    window_x = 1:500:2001;
    window_y = 2000:-500:0;
    windows = {};
    for x = window_x
        for y = window_y
            windows = [windows genvarname(['w_' num2str(x) '_' num2str(y)])];
        end
    end
    p_mean = varfun(f,result,'InputVariables', windows,...
           'GroupingVariables', {'pnum', 'calibrated_words', 'calibrated_values'});

    uniq_words = unique(p_mean.calibrated_words);
    word_keys = 1:length(uniq_words);
    word_code_map = containers.Map(cellstr(uniq_words), word_keys);

    window_score_table = table;

    fprintf('calculating score with sequence obtained by %s of multiple occurence of the same word. \n', char(f));
    for w = windows
        mean_col = genvarname([char(f) '_' w{1}]);
        p_feeltrace = sortrows(p_mean, {'pnum', mean_col});
        p_cali_word = sortrows(p_mean, {'pnum', 'calibrated_values'});

        for i = 1:23
            seq1 = p_feeltrace(p_feeltrace.pnum == i, :).calibrated_words;
            seq2 = p_cali_word(p_cali_word.pnum == i, :).calibrated_words;
            window_score_table.('pnum')(i) = i;
            if ~isempty(seq1)
                seq1_coded = cellfun(@(x) word_code_map(x), seq1);
                seq2_coded = cellfun(@(x) word_code_map(x), seq2);
                score = corr(seq1_coded, seq2_coded, 'Type', 'Kendall');
                window_score_table.(genvarname(['score_' w{1}]))(i) = score;
            end
        end
    end
end