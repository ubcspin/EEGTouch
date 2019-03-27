big_table = processed_data.eeg;
[eeglen, ~] = size(processed_data.eeg);

big_table.feeltrace = interp1(processed_data.feeltrace.timestamp_ms,processed_data.feeltrace.joystick,1:eeglen)';
big_table.fsrA0 = interp1(processed_data.fsr.timestamp_ms,processed_data.fsr.A0,1:eeglen)';
big_table.fsrA1 = interp1(processed_data.fsr.timestamp_ms,processed_data.fsr.A1,1:eeglen)';
big_table.fsrA2 = interp1(processed_data.fsr.timestamp_ms,processed_data.fsr.A2,1:eeglen)';
big_table.fsrA3 = interp1(processed_data.fsr.timestamp_ms,processed_data.fsr.A3,1:eeglen)';
big_table.fsrA4 = interp1(processed_data.fsr.timestamp_ms,processed_data.fsr.A4,1:eeglen)';
big_table.calibrated_words = interp1(processed_data.calibrated_words.timestamp_ms,processed_data.calibrated_words.calibrated_values,1:eeglen)';

big_table.events_game = strings(eeglen,1);
for i = 1:length(processed_data.events.game.timestamp_ms)
    big_table.events_game(processed_data.events.game.timestamp_ms(i)) = processed_data.events.game.label(i);
end
big_table.events_game = standardizeMissing(big_table.events_game,"");
big_table.events_game = fillmissing(big_table.events_game,'nearest');


big_table.events_character = strings(eeglen,1);
for i = 1:length(processed_data.events.character.timestamp_ms)
    big_table.events_character(processed_data.events.character.timestamp_ms(i)) = processed_data.events.character.label(i);
end
big_table.events_character = standardizeMissing(big_table.events_character,"");
big_table.events_character = fillmissing(big_table.events_character,'nearest');

big_table.events_sound = strings(eeglen,1);
for i = 1:length(processed_data.events.sound.timestamp_ms)
    big_table.events_sound(processed_data.events.sound.timestamp_ms(i)) = processed_data.events.sound.label(i);
end
big_table.events_sound = standardizeMissing(big_table.events_sound,"");
big_table.events_sound = fillmissing(big_table.events_sound,'nearest');

big_table.interview = strings(eeglen,1);
for i = 1:length(processed_data.interview.timestamp_ms)
    big_table.interview(processed_data.interview.timestamp_ms(i)) = processed_data.interview.label(i);
end
big_table.interview = standardizeMissing(big_table.interview,"");
big_table.interview = fillmissing(big_table.interview,'nearest');

ft_downsample = NaN(eeglen,1);
for i = 1:10:eeglen
    ft_downsample(i) = big_table.feeltrace(i);
end
ft_downsample = standardizeMissing(ft_downsample,NaN);
ft_downsample = fillmissing(ft_downsample,'nearest');
%big_table.ft_category = diff(big_table.feeltrace);

csv_dir = fullfile(processed_directory,['csv' trial_number]);
status = mkdir(csv_dir);

%for i = 1: 

writetable(big_table,fullfile(csv_dir,['eeg' trial_number '.csv']));