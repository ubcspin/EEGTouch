% Script for generating all visualizations for the current participant. 

% Requirement: EEGLAB is launched, and has a cleaned dataset loaded.

% Ensure that the ../data/Pxx folder also contains:
%       - game_events.mat file, containing the game events. If unavailable, use
%         get_game_events.m to extract game events from processed_data.mat

% Parameters to be set by the user
participant = "P09_ASR20"; % participant number in Pxx format; eg. P09
run_tf = false; % boolean for whether to run time_frequency decomposition (if plotting previously run tf, keep false)
% booleans for which visualizations to plot
plot_general_pd_tf = false; % general power density and time frequency
plot_event_pd_tf = false; % e vent-centered power density and time freqeuncy
plot_frequency_band_power = false; % power over time for all frequency band
plot_alpha_theta = false; % alpha-theta power difference over time
plot_asymmetry = false; % left-right hemispheres power difference over time
% Time-frequency parameters can be edited; see lines 71-82

% Begin visualizations
fprintf('Begin visualization\n');

f = fileparts(pwd);
folder = fullfile(f,'vis',participant);

% conversion from miliseconds to minutes
miliconvert = 1/(1000*60);

% create a folder to hold all the plots
if ~exist(folder, 'dir')
    mkdir(folder)
end

% create a map from electrode names to numbers, since it shifts sometimes; names are constant
channel_names = strings(1,65);
channel_numbers = ones(1,65);
for i = 1:65
    channel_names(i) = EEG.chanlocs(i).labels;
    channel_numbers(i) = EEG.chanlocs(i).urchan - 3; % the -3 is to account for hidden channels
end
channel_map = containers.Map(channel_names,channel_numbers);

extension = ["_delta", "_theta", "_alpha", "_beta", "_gamma"];
band_name = ["Delta", "Theta", "Alpha", "Beta", "Gamma"];

% create a list for the "main" electrodes that we want to visualize on
main_electrodes = ["E5", "E6", "E10", "E12", "E18", "E20", "E24", "E28", "E30", "E34", "E35", "E37", "E39", "E42", "E44", "E50", "E52", "E58", "E60"];
main_electrodes_labels = ["FP2", "FCz", "FP1", "F3", "F7", "C3", "T7", "P3", "P7", "Pz", "O1", "Oz", "O2", "P4", "P8", "C4", "T8", "F8", "F4"];

% create a map of brain regions to corresponding electrodes
brain_regions.RFrontal = ["E6", "E3", "E60", "E8", "E2", "E59", "E5", "E58", "E1"];
brain_regions.LFrontal = ["E6", "E9", "E12", "E8", "E11", "E13", "E10", "E18", "E17"];
brain_regions.RCentral = ["E4", "E54", "E51", "E41", "E53", "E50", "E57", "E49", "E46"];
brain_regions.LCentral = ["E4", "E7", "E16", "E21", "E15", "E20", "E14", "E22", "E26"];
brain_regions.RTemporal = ["E56", "E48", "E52", "E55", "E47"];
brain_regions.LTemporal = ["E19", "E25", "E24", "E23", "E29"];
brain_regions.RParietal = ["E34", "E40", "E42", "E45", "E44"];
brain_regions.LParietal = ["E34", "E31", "E28", "E27", "E30"];
brain_regions.ROccipital = ["E36", "E38", "E37", "E39", "E43"];
brain_regions.LOccipital = ["E36", "E33", "E37", "E35", "E32"];

brain_region_labels = ["RFrontal", "LFrontal", "RCentral", "LCentral", "RTemporal", "LTemporal", "RParietal", "LParietal", "ROccipital", "LOccipital"];

% The ranges of frequencies corresponding to each frequency band
bands.delta = [1, 4];
bands.theta = [4, 7.5];
bands.alpha = [8, 13];
bands.beta = [13,30];
bands.gamma = [30, 50];

% create variables to use for the time-freqency and power density decompositions 
% variable for time range of the dataset, in miliseconds
time_range = [1 EEG.times(end)];
l = EEG.times;
% variable for frequency range, in Hz
freq_range = [1 50]; % [0 50]; % [1 50];
% variable for analysis type; FFT [0] vs wavelets [3 0.5] <- TODO: find proper wavelet setting
cycles = [0]; % [3 0.5]; % [0];
% variable for number of time points to evaluate at
timesout = 5000;
% variable for the number of frequencies to evaluate
numfreqs = 50;

% get the time-frequency decompositions for all the channels, to avoid recomputing later
% NOTE: general time-frequency plots only generated when run_tf == true
if run_tf == true
    fprintf('Running time-frequency decomposition on all channels. This may take a while\n');
    tf_outputs = struct;
    for i = 1:EEG.nbchan
        fprintf('Time-frequency decomposition for channel %i\n', i);
        [mytf,itc,powbase,times,freqs,erspboot,itcboot,tfdata] = pop_newtimef(EEG,1,i,time_range,cycles,'timesout',timesout,'elocs',EEG.chanlocs,'chaninfo',EEG.chaninfo,'freqs',freq_range,'baseline', [0], 'plotitc','off','plotphase','off','plotersp', 'off','nfreqs',numfreqs, 'verbose', 'off');
        tf_outputs(i).tfdata = mytf;
        tf_outputs(i).times = times;
        tf_outputs(i).freqs = freqs;
        tf_outputs(i).powbase = powbase;
        tf_outputs(i).erspboot = erspboot;
    end
    tf_file = fullfile(f, 'data', participant,'tf_outputs.mat');
    save(tf_file, 'tf_outputs');
else
    fprintf('Loading time-frequency data from .m file\n');
    tf_file = fullfile(f, 'data', participant,'tf_outputs.mat');
    load(tf_file);
end

times = tf_outputs(1).times;
freqs = tf_outputs(1).freqs;

% 1. general power density and time-frequency plots
if plot_general_pd_tf == true
   fprintf('Begin general pd & tf visualization\n');
   general_pd_tf; 
end
% 2. time frequency plots centered around interesting game events (see the
% csv in processed_data directory)
if plot_event_pd_tf == true
    fprintf('Begin event centered pd & tf visualization\n');
    event_pd_tf;
end
% 3. frequency band power over time, averaged over the band
if plot_frequency_band_power == true
    fprintf('Begin frequency band power visualization\n');
    frequency_band_power;
end
% 4. difference in alpha and theta power over time, per brain region
if plot_alpha_theta == true
    fprintf('Begin alpha-theta difference visualization\n');
    alpha_theta;
end
% 5. difference in frequency band power in left and right hemisphere, per
% brain region
if plot_asymmetry == true
    fprintf('Begin asymmetry visualization\n');
    asymmetry;
end

fprintf('Task complete!\n');