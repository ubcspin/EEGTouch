function collated_freq_table = convert_to_collated_freq_table(all_data)
    num_trials = 16;
    collated_freq_table = cell(num_trials,1);
    
    for i = 1:length(all_data) 
        fprintf(['Getting frequency table for trial ' all_data{i}.scalars.trial_number '\n']);
        [frequency_table, full_time_ms, f] = freq_table(all_data{i}, NaN);
        collated_freq_table{i}.trial_number = all_data{i}.scalars.trial_number;
        collated_freq_table{i}.freq_table = balance_freq_table(frequency_table);
        collated_freq_table{i}.unbalanced_freq_table = frequency_table;
        collated_freq_table{i}.timestamp_ms = full_time_ms;
        collated_freq_table{i}.f = f;
        
    end
end