% Script for generating plots of frequency band power over time

% Requirement: run from plotting_main

% Output: saves plots to vis/Pxx/band_power_ch and vis/Pxx/band_power_br

% Booleans for whether to plot over channels and brain regions
plot_channels = true;
plot_brain_regions = true;

f = fileparts(pwd);
pfolder = fullfile(f,'vis',participant);

% plot and save the frequency band power over time for each electrode
if plot_channels == true
    fprintf('Plotting the power over time for each main channel (19 total)\n');
    
    folder = fullfile(pfolder,'band_power_ch');
    if ~exist(folder, 'dir')
        mkdir(folder);
    else
        rmdir(folder,'s');
        mkdir(folder);
    end

    % trying to put them all on the same scale
    electrode_powers = zeros(5,length(times),length(main_electrodes));
    for i = 1:length(main_electrodes)
        tfdata = tf_outputs(channel_map(main_electrodes(i))).tfdata;
        freqs = tf_outputs(channel_map(main_electrodes(i))).freqs;
        times = tf_outputs(channel_map(main_electrodes(i))).times;
        times = times*miliconvert;
        
        % extracting the results for each frequency band
        deltaBand = tfdata(freqs>=bands.delta(1) & freqs<bands.delta(2),:);
        thetaBand = tfdata(freqs>=bands.theta(1) & freqs<bands.theta(2),:);
        alphaBand = tfdata(freqs>=bands.alpha(1) & freqs<bands.alpha(2),:);
        betaBand  = tfdata(freqs>=bands.beta(1) & freqs<bands.beta(2),:);
        gammaBand = tfdata(freqs>=bands.gamma(1) & freqs<bands.gamma(2),:);
        
        % the output of the time-frequency decomposition gives the power as 10*log_10(power),
        % but we're interested in absolute power; perform the conversion and get the mean power
        deltaPower = log(mean(10.^(deltaBand/10)));
        thetaPower = log(mean(10.^(thetaBand/10)));
        alphaPower = log(mean(10.^(alphaBand/10)));
        betaPower  = log(mean(10.^(betaBand/10)));
        gammaPower = log(mean(10.^(gammaBand/10)));
        
        avg_powers = vertcat(deltaPower, thetaPower, alphaPower, betaPower, gammaPower);
        electrode_powers(:,:,i) = avg_powers;
    end
            
    % to put all the powers on the same axis, save the maximum & minimum power
    max_avg = max(max(max(electrode_powers)));
    min_avg = min(min(min(electrode_powers)));
    
    for i = 1:length(main_electrodes)
        % save a .png and .fig for each of the frequency bands
        for j = 1:5
            subfolder = fullfile(folder,band_name(j));
            if ~exist(subfolder, 'dir')
                mkdir(subfolder);
            end
            f = figure('visible','off');
            plot(times,squeeze(electrode_powers(j,:,i)));
            xlim([time_range(1)*miliconvert time_range(2)*miliconvert]);
            ylim([min_avg max_avg]);
            title(band_name(j) + ' power over time for channel ' + main_electrodes(i));
            xlabel('Time, in minutes');
            ylabel('Log power difference from baseline, dB');
            set(gca,'XMinorTick','on','YMinorTick','on')
            plotname = fullfile(subfolder,main_electrodes_labels(i));
            saveas(f, plotname + ".fig");
            saveas(f, plotname + ".png");
            close;
        end
        fprintf('Plots complete for channel ' + main_electrodes(i) + '\n');
    end
end

% plot and save the frequency band power per brain region
if plot_brain_regions == true
    
    folder = fullfile(pfolder,'band_power_br');
    if ~exist(folder, 'dir')
        mkdir(folder);
    else
        rmdir(folder,'s');
        mkdir(folder);
    end

    fprintf('Plotting the power over time for each brain region (10 total)\n');
    
    % trying to put them all on the same scale
    br_powers = zeros(5,length(times),length(brain_region_labels));
    for i = 1:length(brain_region_labels)
        br = brain_regions.(brain_region_labels{i});
        channel_delta = zeros(1,length(times));
        channel_theta = zeros(1,length(times));
        channel_alpha = zeros(1,length(times));
        channel_beta = zeros(1,length(times));
        channel_gamma = zeros(1,length(times));
        
        for j = 1:length(br)
            tfdata = tf_outputs(channel_map(br(j))).tfdata;
            freqs = tf_outputs(channel_map(br(j))).freqs;
            times = tf_outputs(channel_map(br(j))).times;
            times = times*miliconvert;
            
            % extracting the results for each frequency band
            deltaBand = tfdata(freqs>=bands.delta(1) & freqs<bands.delta(2),:);
            thetaBand = tfdata(freqs>=bands.theta(1) & freqs<bands.theta(2),:);
            alphaBand = tfdata(freqs>=bands.alpha(1) & freqs<bands.alpha(2),:);
            betaBand  = tfdata(freqs>=bands.beta(1) & freqs<bands.beta(2),:);
            gammaBand = tfdata(freqs>=bands.gamma(1) & freqs<bands.gamma(2),:);
            
            % the output of the time-frequency decomposition gives the power as 10*log_10(power),
            % but we're interested in absolute power; perform the conversion and get the mean power
            deltaPower = mean(10.^(deltaBand/10));
            thetaPower = mean(10.^(thetaBand/10));
            alphaPower = mean(10.^(alphaBand/10));
            betaPower  = mean(10.^(betaBand/10));
            gammaPower = mean(10.^(gammaBand/10));
            
            % add up the band powers over the channels
            channel_delta = channel_delta + deltaPower;
            channel_theta = channel_theta + thetaPower;
            channel_alpha = channel_alpha + alphaPower;
            channel_beta = channel_beta + betaPower;
            channel_gamma = channel_gamma + gammaPower;
        end
        
        % average over number of channels and log the result
        channel_delta = log(channel_delta/length(br));
        channel_theta = log(channel_theta/length(br));
        channel_alpha = log(channel_alpha/length(br));
        channel_beta = log(channel_beta/length(br));
        channel_gamma = log(channel_gamma/length(br));
        
        avg_powers = vertcat(channel_delta, channel_theta, channel_alpha, channel_beta, channel_gamma);
        br_powers(:,:,i) = avg_powers;
    end
    
    % to put all the powers on the same axis, save the maximum & minimum power
    max_avg = max(max(max(br_powers)));
    min_avg = min(min(min(br_powers)));
    
    for i = 1:length(brain_region_labels)
        % save a .png and .fig for each of the frequency bands
        for j = 1:5
            subfolder = fullfile(folder,band_name(j));
            if ~exist(subfolder, 'dir')
                mkdir(subfolder);
            end
            f = figure('visible','off');
            plot(times,squeeze(br_powers(j,:,i)));
            xlim([time_range(1)*miliconvert time_range(2)*miliconvert]);
            ylim([min_avg max_avg]);
            title(band_name(j) + ' power over time for ' + brain_region_labels(i) + ' brain region ');
            xlabel('Time, in minutes');
            ylabel('Log power difference from baseline, dB');
            set(gca,'XMinorTick','on','YMinorTick','on')
            plotname = fullfile(subfolder,brain_region_labels(i));
            saveas(f, plotname + ".fig");
            saveas(f, plotname + ".png");
            close;
        end
        fprintf('Plots complete for ' + brain_region_labels(i) + ' brain region\n');
    end
end



 