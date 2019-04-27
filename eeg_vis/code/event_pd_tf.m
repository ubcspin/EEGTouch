% Script for generating power density and time-frequency plots centered around game events

% Requirement: run from plotting_main

% Ensure that the ../data/Pxx folder also contains:
% 	- game_events.mat, a table of game events where the first column is the 
%     name of the event and the second column is the time (in ms) of occurrance. 

% Output: saves plots to vis/Pxx/event_pd and vis/Pxx/event_tf

% Booleans for whether to plot power-density and time-frequency
event_pd = true;
event_tf = true;

f = fileparts(pwd);
pfolder = fullfile(f,'vis',participant);

% get the game events and times from the .mat file
ge_file = fullfile(f,'data',participant,'game_events.mat');
load(ge_file);
game_evs = table2array(game_events);
game_times = str2double(game_evs(:,2));
game_events = game_evs(:,1);

if event_pd == true
    % generates power-density plots around interesting game events
    folder = fullfile(pfolder,'event_pd');
    if ~exist(folder, 'dir')
        mkdir(folder);
    else 
        rmdir(folder,'s');
        mkdir(folder);
    end
    
    for i = 1:length(game_times)
        event_time = game_times(i);
        window = 20000; % time window after the event, in ms
        f = figure('visible','off');
        if (event_time + window < time_range(2))
            [spectra,specfreqs,speccomp,contrib,specstd] = pop_spectopo(EEG, 1, [event_time, event_time+window], 'EEG' , 'percent', 100, 'freqrange',freq_range);
            title('Power spectrum centered at ' + game_events(i));
            plotname = fullfile(folder,int2str(i) + "_" + game_events(i));
            saveas(f, plotname + ".fig");
            saveas(f, plotname + ".png");
            close;
        end
    end
end

if event_tf == true
    % generates time-frequency plots around interesting game events
    folder = fullfile(pfolder,'event_tf');
    if ~exist(folder, 'dir')
        mkdir(folder);
    end
    
    % generates a time-frequency plot for each channel, for each game event
    for j = 1:length(main_electrodes)
        subfolder = fullfile(folder,main_electrodes_labels(j));
        
        if ~exist(subfolder, 'dir')
            mkdir(subfolder)
        else
            rmdir(subfolder, 's')
            mkdir(subfolder)
        end
        
        for i = 1:length(game_times)
            event_time = game_times(i);
            window = 20000; % time window before and after the event, in ms
            f = figure('visible','off');
            % perform time-frequency decomposition, with max ersp set to 15 dB
            % vertical line at event time
            if (event_time - window > time_range(1)) && (event_time + window < time_range(2))
                [eventtf,eventitc,eventpowbase,eventtimes,eventfreqs,eventerspboot,eventitcboot,eventtfdata] = pop_newtimef(EEG,1,j,[event_time-window, event_time+window],cycles,'timesout',200,'elocs',EEG.chanlocs,'chaninfo',EEG.chaninfo,'freqs',freq_range,'baseline', [0], 'plotitc','off','plotphase','off','plotersp', 'on','nfreqs',numfreqs, 'verbose', 'off', 'erspmax', 15, 'vert',[event_time]);
                title('Time frequency centered at ' + game_events(i));
                plotname = fullfile(subfolder,int2str(i) + "_" + game_events(i));
                saveas(f, plotname + ".fig");
                saveas(f, plotname + ".png");
                close;
            end
        end
    end
end