%% PROCESSES ALL SUMMARY DATA INTO TABLEAU-READY CSV FILES 

load_all_processed;

all_summary = table('Size', [0 4], 'VariableTypes', {'double', 'double', 'double', 'double'}, 'VariableNames', {'pnum', 'total_ms', 'interview_num', 'word_point_num'});

for i = 1:size(all_data,1)
    pfile = all_data{i,1};
    
    if ~isempty(pfile)
        fprintf('Extracting time data from participant %d...\n', i);
        
        game_start = pfile.interview{1,1};
        game_end_tmp = tail(pfile.events.game_controlled_visual, 1);
        game_end = game_end_tmp{1,1};
        
        duration = game_end - game_start;
        if duration < 0 
            game_end_tmp = tail(pfile.interview, 1);
            game_end = game_end_tmp{1,1};
            duration = game_end - game_start;
        end
        
        current_summary.pnum = i;
        current_summary.total_ms = duration;
        current_summary.interview_num = size(pfile.interview, 1);
        current_summary.word_point_num = size(pfile.calibrated_words, 1);
       
        all_summary = [all_summary; struct2table(current_summary)];
    end
end

writetable(all_summary, './tableau/summary.csv');

clearvars i pfile game_start game_end_tmp game_end current_summary duration
