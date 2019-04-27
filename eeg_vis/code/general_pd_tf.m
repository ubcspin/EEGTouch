% Script for generating general power density and time-frequency plots

% Requirement: run from plotting_main

% Output: saves plots to vis/Pxx/general_pd and vis/Pxx/general_tf

% Booleans for whether to plot power-density and time-frequency
plot_pd = true;
plot_tf = true;

f = fileparts(pwd);
pfolder = fullfile(f,'vis',participant);

if plot_pd == true
    folder = fullfile(pfolder,'general_pd'); 
    
    if ~exist(folder, 'dir')
        mkdir(folder);
    else
        rmdir(folder,'s');
        mkdir(folder);
    end
    
    % generate and save the power density plot
    f = figure('visible','off');
    [spectra,specfreqs,speccomp,contrib,specstd] = spectopo(EEG.data, 0, 250,'freqrange',[1 50]);
    title('Power spectrum');
    plotname = fullfile(folder,'power_spectrum');
    saveas(f, plotname + ".fig");
    saveas(f, plotname + ".png");
    close;
end

if plot_tf == true
    folder = fullfile(pfolder,'general_tf'); 
    
    if ~exist(folder, 'dir')
        mkdir(folder);
    else
        rmdir(folder,'s');
        mkdir(folder);
    end
    
    % generate a time-frequency plot for each main channel
    for i = 1:length(main_electrodes)
        tfdata = tf_outputs(channel_map(main_electrodes(i))).tfdata;
        freqs = tf_outputs(channel_map(main_electrodes(i))).freqs;
        times = tf_outputs(channel_map(main_electrodes(i))).times;
        times = times*miliconvert;

        %  TODO: how to add the legends for the time-frequency plots?! I
        %  set the ersp range to -15 to 15 dB
        f = figure('visible','off');
        tftopo(tfdata,times,freqs,'limits',[NaN,NaN,NaN,NaN,-15,15],'smooth',2);
        title('ERSP for channel ' + main_electrodes_labels(i));
        xlabel('Time, in minutes');
        plotname = fullfile(folder,main_electrodes_labels(i)); 
        saveas(f, plotname + ".fig");
        saveas(f, plotname + ".png");
        close;
    end
    
    
    % Performing time-frequency decompositions on all electrodes to get the average
    outs = zeros(length(freqs),length(times),length(tf_outputs));
    for i = 1:length(tf_outputs)
        outs(:,:,i) = tf_outputs(i).tfdata;
    end
    
    f = figure('visible','off');
    tftopo(outs,times,freqs,'mode','ave','chanlocs', EEG.chanlocs, 'smooth',2);
    title('Averaged ERSP over all channels');
    xlabel('Time, in minutes');
    plotname = fullfile(folder,'average');
    saveas(f, plotname + ".fig");
    saveas(f, plotname + ".png");
    close;
end