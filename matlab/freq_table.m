load_globals;

% Split of frequency bands
freq_split = 256;
% Maximum frequency cutoff (inclusive)
freq_cutoff = 50;
% Window length (flat window)
window_len = 1000;
% Window overlap
overlap = 900;
% Samplling rate (Hz)
s_rate = 1000;

% Prelim pectrogram to establish table size
[s,f,t] = spectrogram(processed_data.eeg.eeg(:,1),window_len,overlap,freq_split,s_rate,'onesided');
% Find last frequency band to keep
a = find(f>freq_cutoff,1,'first');
% Extend time to from 0:00
t_bump = 0:0.1:t(1)-0.1;
% Create empty array to load in data
freqs = zeros(64,length(t)+length(t_bump),a);

% Create empty table
med_table = table;

% Length of original EEG recording
[eeglen, ~] = size(processed_data.eeg);
%freqs_table = [];
names_num = 1:64;
names_str = strtrim(cellstr(num2str(names_num'))');
t_millis = t*1000;
t_bump = 0:0.1:t(1)-0.1;
lead = zeros(a,length(t_bump));
subnums = num2str(subnames_num');
if a > 9
   subnums(1:9,1) = '0';
end
full_time = [t t_bump];

%subnames_num = 1:a;
%names_str = strtrim(cellstr(repmat("ch1_",a,1) + num2str(subnames_num'))');

for i = 1:64
    [s,f,t] = spectrogram(processed_data.eeg.eeg(:,i),1000,900,freq_split,1000,'onesided');
    with_lead = [lead abs(s(1:a,:))]';
    %freqs(i,:,:) = with_lead;
    subnames_str = strtrim(cellstr(char(repmat(string(['ch' num2str(i) '_']),a,1)) + string(subnums))');
    freqs_minitab = array2table(double(with_lead),'VariableNames',subnames_str);
    %table(with_lead(1:a),'VariableNames',subnames_str);
    %freqs_table = [freqs_table double(with_lead)];
    med_table = [med_table freqs_minitab];
end




% med_table = table(squeeze(freqs(64,:,:)),'VariableNames',"ch1");
% 
% 
% 
% for i = 2:64
%     med_table = addvars(med_table, squeeze(freqs(i,:,:)),'NewVariableNames',string(['ch' names_str{i}]));
% end

feeltrace = interp1(processed_data.feeltrace.timestamp_ms,processed_data.feeltrace.joystick,1:eeglen)';
ft_down = downsample(feeltrace,100);
ft_down = ft_down(1:length(full_time));
wind = [-1 zeros(1,10) 1];
conv_ft = conv(ft_down',wind)';
conv_ft = conv_ft(1:length(full_time));
conv_ov5 = conv_ft > 5;
conv_min5 = conv_ft < -5;
convs = conv_ov5 + conv_min5*-1;
convs_cat = [conv_ov5 conv_min5 ~(conv_ov5 & conv_min5)];
med_table = addvars(med_table, convs, 'NewVariableNames',"ft_slopecat");
med_table = addvars(med_table, ft_down, 'NewVariableNames',"feeltrace");




fsrA0 = downsample(interp1(processed_data.fsr.timestamp_ms,processed_data.fsr.A0,1:eeglen),100)';
med_table.fsrA0 = fsrA0(1:length(full_time));
freqs_table = [freqs_table med_table.fsrA0];

fsrA1 = downsample(interp1(processed_data.fsr.timestamp_ms,processed_data.fsr.A1,1:eeglen),100)';
med_table.fsrA1 = fsrA1(1:length(full_time));
freqs_table = [freqs_table med_table.fsrA1];

fsrA2 = downsample(interp1(processed_data.fsr.timestamp_ms,processed_data.fsr.A2,1:eeglen),100)';
med_table.fsrA2 = fsrA2(1:length(full_time));
freqs_table = [freqs_table med_table.fsrA2];

fsrA3 = downsample(interp1(processed_data.fsr.timestamp_ms,processed_data.fsr.A3,1:eeglen),100)';
med_table.fsrA3 = fsrA3(1:length(full_time));
freqs_table = [freqs_table med_table.fsrA3];

fsrA4 = downsample(interp1(processed_data.fsr.timestamp_ms,processed_data.fsr.A4,1:eeglen),100)';
med_table.fsrA4 = fsrA4(1:length(full_time));
freqs_table = [freqs_table med_table.fsrA4];

calibrated_words = downsample(interp1(processed_data.calibrated_words.timestamp_ms,processed_data.calibrated_words.calibrated_values,1:eeglen,'nearest','extrap'),100)';
med_table.calibrated_words = calibrated_words(1:length(full_time));
freqs_table = [freqs_table med_table.calibrated_words];

events_game = strings(eeglen,1);
for i = 1:length(processed_data.events.game.timestamp_ms)
    events_game(processed_data.events.game.timestamp_ms(i)) = processed_data.events.game.label(i);
end
events_game = standardizeMissing(events_game,"");
events_game = downsample(fillmissing(events_game,'nearest'),100);
med_table.events_game = events_game(1:length(full_time));
freqs_table = [freqs_table grp2idx(categorical(med_table.events_game))];

events_sound = strings(eeglen,1);
for i = 1:length(processed_data.events.sound.timestamp_ms)
    events_sound(processed_data.events.sound.timestamp_ms(i)) = processed_data.events.sound.label(i);
end
events_sound = standardizeMissing(events_sound,"");
events_sound = downsample(fillmissing(events_sound,'nearest'),100);
med_table.events_sound = events_sound(1:length(full_time));
freqs_table = [freqs_table grp2idx(categorical(med_table.events_sound))];

events_char = strings(eeglen,1);
for i = 1:length(processed_data.events.character.timestamp_ms)
    events_char(processed_data.events.character.timestamp_ms(i)) = processed_data.events.character.label(i);
end
events_char = standardizeMissing(events_char,"");
events_char = downsample(fillmissing(events_char,'nearest'),100);
med_table.events_char = events_char(1:length(full_time));
freqs_table = [freqs_table grp2idx(categorical(med_table.events_char))];

interview = strings(eeglen,1);
for i = 1:length(processed_data.interview.timestamp_ms)
    interview(processed_data.interview.timestamp_ms(i)) = processed_data.interview.label(i);
end
interview = standardizeMissing(interview,"");
interview = downsample(fillmissing(interview,'nearest'),100);
med_table.interview = interview(1:length(full_time));
freqs_table = [freqs_table grp2idx(categorical(med_table.interview))];


%med_table_noncat = removevars(med_table,{'ft_slopecat'});
%med_table_noncat = addvars(med_table_noncat, ft_down,'NewVariableNames',"feeltrace");

rand_factor = 6;
rand_col = randi(rand_factor,height(med_table),1);
rand_col = (med_table.ft_slopecat ~= 0) | (rand_col == rand_factor);
med_table_balanced = med_table;
med_table_balanced.rand_col = rand_col;
med_table_balanced(~med_table_balanced.rand_col == true, :) = [];
med_table_balanced = removevars(med_table_balanced,{'rand_col'});

% 
% fieldies = fieldnames(med_table);
% med_table_balanced = table;
% rand_factor = 3;
% k = 1;
% for i = 1:height(med_table)
%     if (med_table.ft_slopecat(i) ~= 0) || (randi(rand_factor) == rand_factor)
%         for j = 1:length(fieldies)-3
%             med_table_balanced.(fieldies{j})(k) = med_table.(fieldies{j})(i);
%         end
%         k = k+1;
%     end
% end
%%%
%med_table = addvars(squeeze(freqs(64,:,:)),'NewVariableNames','1');
%%%

%big_table = processed_data.eeg;
% [eeglen, ~] = size(processed_data.eeg);
% 
% 
% %big_table.feeltrace = interp1(processed_data.feeltrace.timestamp_ms,processed_data.feeltrace.joystick,1:eeglen)';
% big_table.fsrA0 = interp1(processed_data.fsr.timestamp_ms,processed_data.fsr.A0,1:eeglen)';
% big_table.fsrA1 = interp1(processed_data.fsr.timestamp_ms,processed_data.fsr.A1,1:eeglen)';
% big_table.fsrA2 = interp1(processed_data.fsr.timestamp_ms,processed_data.fsr.A2,1:eeglen)';
% big_table.fsrA3 = interp1(processed_data.fsr.timestamp_ms,processed_data.fsr.A3,1:eeglen)';
% big_table.fsrA4 = interp1(processed_data.fsr.timestamp_ms,processed_data.fsr.A4,1:eeglen)';
% big_table.calibrated_words = interp1(processed_data.calibrated_words.timestamp_ms,processed_data.calibrated_words.calibrated_values,1:eeglen)';
% 
% big_table.events_game = strings(eeglen,1);
% for i = 1:length(processed_data.events.game.timestamp_ms)
%     big_table.events_game(processed_data.events.game.timestamp_ms(i)) = processed_data.events.game.label(i);
% end
% big_table.events_game = standardizeMissing(big_table.events_game,"");
% big_table.events_game = fillmissing(big_table.events_game,'nearest');
% 
% 
% big_table.events_character = strings(eeglen,1);
% for i = 1:length(processed_data.events.character.timestamp_ms)
%     big_table.events_character(processed_data.events.character.timestamp_ms(i)) = processed_data.events.character.label(i);
% end
% big_table.events_character = standardizeMissing(big_table.events_character,"");
% big_table.events_character = fillmissing(big_table.events_character,'nearest');
% 
% big_table.events_sound = strings(eeglen,1);
% for i = 1:length(processed_data.events.sound.timestamp_ms)
%     big_table.events_sound(processed_data.events.sound.timestamp_ms(i)) = processed_data.events.sound.label(i);
% end
% big_table.events_sound = standardizeMissing(big_table.events_sound,"");
% big_table.events_sound = fillmissing(big_table.events_sound,'nearest');
% 
% big_table.interview = strings(eeglen,1);
% for i = 1:length(processed_data.interview.timestamp_ms)
%     big_table.interview(processed_data.interview.timestamp_ms(i)) = processed_data.interview.label(i);
% end
% big_table.interview = standardizeMissing(big_table.interview,"");
% big_table.interview = fillmissing(big_table.interview,'nearest');
% 
% ft_downsample = NaN(eeglen,1);
% for i = 1:10:eeglen
%     ft_downsample(i) = big_table.feeltrace(i);
% end
% ft_downsample = standardizeMissing(ft_downsample,NaN);
% ft_downsample = fillmissing(ft_downsample,'nearest');
% %big_table.ft_category = diff(big_table.feeltrace);

csv_dir = fullfile(processed_directory,['csv' trial_number]);
status = mkdir(csv_dir);

writetable(med_table,fullfile(csv_dir,['freqs' trial_number '.csv']));

%clearvars a calibrated_words conv_ft conv_min5 conv_ov5 csv_dir eeglen events_char events_game events_sound feeltrace freqs fsrA0 fsrA1 fsrA2 fsrA3 fsrA4 ft_down i interview lead names_num names_str status t_bump t_millis wind with_lead