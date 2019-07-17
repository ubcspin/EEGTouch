function balanced_table = balance_freq_table(frequency_table)

rand_factor = round(sum(frequency_table.js_slopecat==0)/sum(frequency_table.js_slopecat==1));
rand_col = randi(rand_factor,height(frequency_table),1);
rand_col = (frequency_table.js_slopecat ~= 0) | (rand_col == rand_factor);
balanced_table = frequency_table;
balanced_table.rand_col = rand_col;
balanced_table(~balanced_table.rand_col == true, :) = [];
balanced_table = removevars(balanced_table,{'rand_col'});

%clearvars rand_factor rand_col;