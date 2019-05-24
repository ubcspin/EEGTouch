function [frequency_table, full_time_ms, f] = freq_table(data_table, processed_directory)
%load_globals;

% Split of frequency bands
freq_split = 128;
% Maximum frequency cutoff (inclusive)
freq_cutoff = 16;
% Window (vector, or scalar for flat length)
window_val = hann(100);
% Window overlap
overlap = 0;
% Samplling rate (Hz)
s_rate = 1000;
% Number of EEG channels
num_channels = 64;
% Window size for feeltrace convolution
feeltrace_window = 10;
% Slope cutoff for feeltrace slope categorization
feeltrace_slopecut = 5;

% Prelim spectrogram to establish table size
[s,f,t] = spectrogram(data_table.eeg.eeg(:,1),window_val,overlap,freq_split,s_rate,'onesided');
% Time interval in milliseconds
time_interval = round((t(2) - t(1))*1000);
% Find last frequency band to keep
freq_cut_idx = find(f>freq_cutoff,1,'first');
% Extend time to from 0:00
time_lead = 0:time_interval/1000:t(1)-(time_interval/1000);

% Create empty table
frequency_table = table;

% Length of original EEG recording
[eeglen, ~] = size(data_table.eeg);

% Time vector
full_time = [t time_lead];
% Time vector in milliseconds
full_time_ms = full_time*1000;

% Leading zeros for EEG spectrogram
lead_zeros = zeros(freq_cut_idx,length(time_lead));
% channel number strings for table fields
freq_band_nums = 1:freq_cut_idx;
freq_band_chars = num2str(freq_band_nums');
if freq_cut_idx > 9
   freq_band_chars(1:9,1) = '0';
end

% Spectrogram for each EEG channel
for i = 1:num_channels
    % compute spectrogram
    [s,f,t] = spectrogram(data_table.eeg.eeg(:,i),window_val,overlap,freq_split,s_rate,'onesided');
    % add leading zeros to frequency matrix
    frequencies_with_lead = [lead_zeros abs(s(1:freq_cut_idx,:))]';
    % string of band labels with channel number eg "ch1_1"
    ch_freq_band_str = strtrim(cellstr(char(repmat(string(['ch' num2str(i) '_']),freq_cut_idx,1)) + string(freq_band_chars))');
    channel_frequency_table = array2table(double(frequencies_with_lead),'VariableNames',ch_freq_band_str);
    frequency_table = [frequency_table channel_frequency_table];
end

% interpolate irregularly-sampled feeltrace to EEG sampling frequency
feeltrace = interp1(data_table.feeltrace.timestamp_ms,data_table.feeltrace.joystick,1:eeglen)';
% downsample to spectrogram sample rate & cut to size
ft_downsampled = downsample(feeltrace,time_interval);
ft_downsampled = ft_downsampled(1:length(full_time));
% add to table
feeltrace_table = table(ft_downsampled, 'VariableNames', "feeltrace");
feeltrace_table = fillmissing(feeltrace_table,'nearest');
frequency_table = [feeltrace_table frequency_table];

% Convolution window vector for approx slopes
ft_window = [-1 zeros(1,max(0,feeltrace_window-2)) 1];
% Apply to downsampled feeltrace & trim to size
conv_ft = conv(ft_downsampled',ft_window)';
conv_ft = conv_ft(1:length(full_time));
% Find slopes above and below threshold cutoff
conv_ft_slope_above = conv_ft > feeltrace_slopecut;
conv_ft_slope_poslow = (conv_ft > 0) & (conv_ft <= feeltrace_slopecut);
conv_ft_slope_below = conv_ft <= -(feeltrace_slopecut);
conv_ft_slope_neglow = (conv_ft <= 0) & (conv_ft > -(feeltrace_slopecut));
% Convert to integer categories
conv_ft_slope_cat = conv_ft_slope_above + conv_ft_slope_below*-1;
conv_ft_slope_multicat = conv_ft_slope_above*2 + conv_ft_slope_poslow + conv_ft_slope_neglow*-1 + conv_ft_slope_below*-2;
% Optional categorical vectors (for logical classifiers)
%convs_cat = [conv_slope_above conv_slope_below ~(conv_slope_above & conv_slope_below)];
ft_slopecat_table = table(conv_ft_slope_cat, 'VariableNames', "ft_slopecat");
ft_slopemulticat_table = table(conv_ft_slope_multicat, 'VariableNames', "ft_slopecat_mult");
frequency_table = [ft_slopecat_table frequency_table];
frequency_table = [ft_slopemulticat_table frequency_table];
%frequency_table = addvars(frequency_table, conv_ft_slope_cat, 'NewVariableNames',"ft_slopecat");

fsr_times = data_table.fsr.timestamp_ms;
frequency_table.fsrA0 = downsample_fsr(data_table.fsr.A0, fsr_times, time_interval, eeglen, full_time);
frequency_table.fsrA1 = downsample_fsr(data_table.fsr.A1, fsr_times, time_interval, eeglen, full_time);
frequency_table.fsrA2 = downsample_fsr(data_table.fsr.A2, fsr_times, time_interval, eeglen, full_time);
frequency_table.fsrA3 = downsample_fsr(data_table.fsr.A3, fsr_times, time_interval, eeglen, full_time);
frequency_table.fsrA4 = downsample_fsr(data_table.fsr.A4, fsr_times, time_interval, eeglen, full_time);

frequency_table.events_game = downsample_text(data_table.events.game.label, data_table.events.game.timestamp_ms, time_interval, eeglen, full_time);
frequency_table.events_sound = downsample_text(data_table.events.sound.label, data_table.events.sound.timestamp_ms, time_interval, eeglen, full_time);
frequency_table.events_character = downsample_text(data_table.events.character.label, data_table.events.character.timestamp_ms, time_interval, eeglen, full_time);
frequency_table.inteview = downsample_text(data_table.interview.label, data_table.interview.timestamp_ms, time_interval, eeglen, full_time);

calibrated_words = downsample(interp1(data_table.calibrated_words.timestamp_ms,data_table.calibrated_words.calibrated_values,1:eeglen,'nearest','extrap'),100)';
frequency_table.calibrated_words = calibrated_words(1:length(full_time));

% save to file - matlab
balanced_frequency_table = balance_freq_table(frequency_table);
save(fullfile(processed_directory, [data_table.scalars.trial_number '_frequency_table.mat']),'frequency_table','balanced_frequency_table','f','full_time_ms');

% save to file - csv
csv_dir = fullfile(processed_directory,['csv' data_table.scalars.trial_number]);
status = mkdir(csv_dir);
writetable(frequency_table,fullfile(csv_dir,['freqs' data_table.scalars.trial_number '.csv']));
end

function downsampled_fsr = downsample_fsr(fsr_vector, fsr_time_vector, time_interval, eeglen, full_time)
downsampled_fsr = downsample(interp1(fsr_time_vector,fsr_vector,1:eeglen),time_interval)';
downsampled_fsr = downsampled_fsr(1:length(full_time));
end

function downsampled_text = downsample_text(text_vector, text_time_vector, time_interval, eeglen, full_time)
text_ds = strings(eeglen,1);
if length(text_time_vector) > 1
    for i = 1:length(text_time_vector)
        text_ds(text_time_vector(i)) = text_vector(i);
    end
end
text_ds = standardizeMissing(text_ds,"");
text_ds = downsample(fillmissing(text_ds,'nearest'),time_interval);
downsampled_text = text_ds(1:length(full_time));
end