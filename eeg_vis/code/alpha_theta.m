% Script for generating plots of the difference between the alpha and theta band power over time
% 
% Requirement: run from plotting_main
% 
% Output: saves plots to vis/Pxx/alpha_theta_ch and vis/Pxx/alpha_theta_br

% Booleans for whether to plot over channels and brain regions
plot_channels = true;
plot_brain_regions = true;

f = fileparts(pwd);
pfolder = fullfile(f,'vis',participant);

% plot and save the alpha-theta difference over time for each electrode
if plot_channels == true
    fprintf('Plotting the alpha-theta difference for each main channel (19 total)\n');
    
    folder = fullfile(pfolder,'alpha_theta_ch');
    if ~exist(folder, 'dir')
        mkdir(folder);
    else
        rmdir(folder,'s');
        mkdir(folder);
    end
    
    % trying to put them all on the same scale
    electrode_powers = zeros(3,length(times),length(main_electrodes));
    for i = 1:length(main_electrodes)
        tfdata = tf_outputs(channel_map(main_electrodes(i))).tfdata;
        freqs = tf_outputs(channel_map(main_electrodes(i))).freqs;
        times = tf_outputs(channel_map(main_electrodes(i))).times;
        times = times*miliconvert;
        
        % extracting the results for the alpha and theta band
        thetaBand = tfdata(freqs>=bands.theta(1) & freqs<bands.theta(2),:);
        alphaBand = tfdata(freqs>=bands.alpha(1) & freqs<bands.alpha(2),:);
        
        % the output of the time-frequency decomposition gives the power as 10*log_10(power),
        % but we're interested in absolute power; perform the conversion and get the mean power
        thetaPower = log(mean(10.^(thetaBand/10)));
        alphaPower = log(mean(10.^(alphaBand/10)));
        diff = alphaPower - thetaPower; % order chosen because we expect alpha decrease, theta increase
        
        powers = vertcat(thetaPower,alphaPower, diff);
        electrode_powers(:,:,i) = powers;
    end
    
    % to put them on the same scales
    ymin = min(min(min(electrode_powers)));
    ymax = max(max(max(electrode_powers)));
        
    for i = 1:length(main_electrodes)
        % create a subplot of alpha, theta and difference for each channel
        f = figure('visible','off');
        subplot(3,1,1);
        plot(times,electrode_powers(2,:,i));
        xlim([time_range(1)*miliconvert time_range(2)*miliconvert]);
        ylim([ymin ymax]);
        title('Alpha power over time for channel ' + main_electrodes(i));
        set(gca,'XMinorTick','on','YMinorTick','on')
        subplot(3,1,2);
        plot(times,electrode_powers(1,:,i));
        xlim([time_range(1)*miliconvert time_range(2)*miliconvert]);
        ylim([ymin ymax]);
        title('Theta power over time for channel ' + main_electrodes(i));
        set(gca,'XMinorTick','on','YMinorTick','on')
        subplot(3,1,3);
        plot(times,electrode_powers(3,:,i));
        xlim([time_range(1)*miliconvert time_range(2)*miliconvert]);
        ylim([ymin ymax]);
        title('Difference in Alpha and Theta power over time for channel ' + main_electrodes(i));
        xlabel('Time, in minutes');
        ylabel('Difference in log power, dB');
        set(gca,'XMinorTick','on','YMinorTick','on')
        plotname = fullfile(folder,main_electrodes_labels(i));
        saveas(f, plotname + ".fig");
        saveas(f, plotname + ".png");
        close;
        
        fprintf("Plot complete for channel " + main_electrodes(i) + "\n");
    end
end


% plot and save the alpha-theta difference per brain region
if plot_brain_regions == true
    
    folder = fullfile(pfolder,'alpha_theta_br');
    if ~exist(folder, 'dir')
        mkdir(folder);
    else
        rmdir(folder,'s');
        mkdir(folder);
    end

    fprintf('Plotting the alpha-theta difference each brain region (10 total)\n');
    
    % trying to put them all on the same scale
    br_powers = zeros(3,length(times),length(brain_region_labels));
    for i = 1:length(brain_region_labels)
        br = brain_regions.(brain_region_labels{i});
        channel_theta = zeros(1,length(times));
        channel_alpha = zeros(1,length(times));
        
        for j = 1:length(br)
            tfdata = tf_outputs(channel_map(br(j))).tfdata;
            freqs = tf_outputs(channel_map(br(j))).freqs;
            times = tf_outputs(channel_map(br(j))).times;
            times = times*miliconvert;
            
            % extracting the results for each frequency band
            thetaBand = tfdata(freqs>=bands.theta(1) & freqs<bands.theta(2),:);
            alphaBand = tfdata(freqs>=bands.alpha(1) & freqs<bands.alpha(2),:);
            
            % the output of the time-frequency decomposition gives the power as 10*log_10(power),
            % but we're interested in absolute power; perform the conversion and get the mean power
            thetaPower = mean(10.^(thetaBand/10));
            alphaPower = mean(10.^(alphaBand/10));
            
            % add up the band powers over the channels
            channel_theta = channel_theta + thetaPower;
            channel_alpha = channel_alpha + alphaPower;
        end
        
        % average over number of channels and log the result
        channel_theta = log(channel_theta/length(br));
        channel_alpha = log(channel_alpha/length(br));
        channel_diff = channel_alpha - channel_theta;
        
        avg_powers = vertcat(channel_theta, channel_alpha, channel_diff);
        br_powers(:,:,i) = avg_powers;
    end
    
    % to put all the powers on the same axis, save the maximum & minimum power
    ymax = max(max(max(br_powers)));
    ymin = min(min(min(br_powers)));
       
    for i = 1:length(brain_region_labels)
        % create a subplot of alpha, theta and difference for each brain region
        f = figure('visible','off');
        subplot(3,1,1);
        plot(times,br_powers(2,:,i));
        xlim([time_range(1)*miliconvert time_range(2)*miliconvert]);
        ylim([ymin ymax]);
        title('Alpha power over time for ' + brain_region_labels(i) + ' brain region ');
        set(gca,'XMinorTick','on','YMinorTick','on')
        subplot(3,1,2);
        plot(times,br_powers(1,:,i));
        xlim([time_range(1)*miliconvert time_range(2)*miliconvert]);
        ylim([ymin ymax]);
        title('Theta power over time for ' + brain_region_labels(i) + ' brain region ');
        set(gca,'XMinorTick','on','YMinorTick','on')
        subplot(3,1,3);
        plot(times,br_powers(3,:,i));
        xlim([time_range(1)*miliconvert time_range(2)*miliconvert]);
        ylim([ymin ymax]);
        title('Difference in Alpha and Theta power over time for ' + brain_region_labels(i) + ' brain region ');
        xlabel('Time, in minutes');
        ylabel('Difference in log power, dB');
        set(gca,'XMinorTick','on','YMinorTick','on')
        plotname = fullfile(folder,brain_region_labels(i));
        saveas(f, plotname + ".fig");
        saveas(f, plotname + ".png");
        close;
        
        fprintf('Plots complete for ' + brain_region_labels(i) + ' brain region\n');
    end
end