% Script for generating plots of the difference between the left and right hemisphere over
% 
% Requirement: run from plotting_main
% 
% Output: saves plots to vis/Pxx/asymmetry_ch and vis/Pxx/asymmetry_br

% Booleans for whether to plot over channels and brain regions
plot_channels = true;
plot_brain_regions = true;

f = fileparts(pwd);
pfolder = fullfile(f,'vis',participant);

left_labels = ["FP1", "F3", "F7", "C3", "T7", "P3", "P7", "O1"];
left_channels = ["E10", "E12", "E18", "E20", "E24", "E28", "E30", "E35"];
right_labels = ["FP2", "F4", "F8", "C4", "T8", "P4", "P8", "O2"];
right_channels = ["E5", "E60", "E58", "E50", "E52", "E42", "E44", "E39"];

% plot and save the asymmetry over time for each electrode
if plot_channels == true
    fprintf('Plotting the left vs right asymmetry on corresponding pairs of main channels (7 total)\n');
   
    folder = fullfile(pfolder,'asymmetry_ch');
    if ~exist(folder, 'dir')
        mkdir(folder);
    else
        rmdir(folder,'s');
        mkdir(folder);
    end

    % trying to put them all on the same scale
    electrode_powers = zeros(3, 5,length(times),length(left_channels));
    for i = 1:length(left_channels)
        for j = 1:2
            if j == 1
                lr_channels = left_channels;
            else
                lr_channels = right_channels;
            end
            
            tfdata = tf_outputs(channel_map(lr_channels(i))).tfdata;
            freqs = tf_outputs(channel_map(lr_channels(i))).freqs;
            times = tf_outputs(channel_map(lr_channels(i))).times;
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
        
            if j == 1
                l_powers = vertcat(deltaPower, thetaPower, alphaPower, betaPower, gammaPower);
            else 
                r_powers = vertcat(deltaPower, thetaPower, alphaPower, betaPower, gammaPower);
            end
        end
        
        diff_powers = l_powers - r_powers;
        
        electrode_powers(1,:,:,i) = l_powers;
        electrode_powers(2,:,:,i) = r_powers;
        electrode_powers(3,:,:,i) = diff_powers;
    end
            
    % to put all the powers on the same axis, save the maximum & minimum power
    ymax = max(max(max(max(electrode_powers))));
    ymin = min(min(min(min(electrode_powers))));
    
    for i = 1:length(left_channels)
        for j = 1:5
            subfolder = fullfile(folder,band_name(j));
            if ~exist(subfolder, 'dir')
                mkdir(subfolder);
            end
            % for each frequency band, create a subplot of left, right and difference for each pair
            f = figure('visible','off');
            subplot(3,1,1);
            plot(times,squeeze(electrode_powers(1,j,:,i)));
            xlim([time_range(1)*miliconvert time_range(2)*miliconvert]);
            ylim([ymin ymax]);
            title(band_name(j) + ' power over time for channel ' + left_channels(i));
            set(gca,'XMinorTick','on','YMinorTick','on')
            subplot(3,1,2);
            plot(times,squeeze(electrode_powers(2,j,:,i)));
            xlim([time_range(1)*miliconvert time_range(2)*miliconvert]);
            ylim([ymin ymax]);
            title(band_name(j) + ' power over time for channel ' + right_channels(i));
            set(gca,'XMinorTick','on','YMinorTick','on')
            subplot(3,1,3);
            plot(times,squeeze(electrode_powers(3,j,:,i)));
            xlim([time_range(1)*miliconvert time_range(2)*miliconvert]);
            ylim([ymin ymax]);
            title('Difference in Left and Right ' + band_name(j) + ' power over time');
            xlabel('Time, in minutes');
            ylabel('Difference in log power, dB');
            set(gca,'XMinorTick','on','YMinorTick','on')
            plotname = fullfile(subfolder, left_labels(i) + "_" + right_labels(i));
            saveas(f, plotname + ".fig");
            saveas(f, plotname + ".png");
            close;
        end
        fprintf("Plot complete for channels " + left_labels(i) + " and " + right_labels(i) + "\n");
    end
end

% plot and save the frequency band power per brain region
if plot_brain_regions == true
   
    folder = fullfile(pfolder,'asymmetry_br');
    if ~exist(folder, 'dir')
        mkdir(folder);
    else
        rmdir(folder,'s');
        mkdir(folder);
    end

    fprintf('Plotting the left vs right asymmetry on corresponding pairs of brain regions (5 total)\n');
    
    % trying to put them all on the same scale
    br_powers = zeros(3,5,length(times),length(brain_region_labels)/2);
    for i = 1:length(brain_region_labels)/2
        br_left = brain_regions.(brain_region_labels{2*i-1});
        br_right = brain_regions.(brain_region_labels{2*i});
        l_channel_bands = zeros(5,length(times));
        r_channel_bands = zeros(5,length(times));
        
        for j = 1:length(br_left)
            for k = 1:2
                if k == 1
                    br = br_left;
                else 
                    br = br_right;
                end
                
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
                if k == 1
                    l_channel_bands(1,:) = l_channel_bands(1,:) + deltaPower;
                    l_channel_bands(2,:) = l_channel_bands(2,:) + thetaPower;
                    l_channel_bands(3,:) = l_channel_bands(3,:) + alphaPower;
                    l_channel_bands(4,:) = l_channel_bands(4,:) + betaPower;
                    l_channel_bands(5,:) = l_channel_bands(5,:) + gammaPower;
                else
                    r_channel_bands(1,:) = r_channel_bands(1,:) + deltaPower;
                    r_channel_bands(2,:) = r_channel_bands(2,:) + thetaPower;
                    r_channel_bands(3,:) = r_channel_bands(3,:) + alphaPower;
                    r_channel_bands(4,:) = r_channel_bands(4,:) + betaPower;
                    r_channel_bands(5,:) = r_channel_bands(5,:) + gammaPower;
                end
            end     
        end
        
        % average over number of channels and log the result
        for j = 1:5
            l_channel_bands(j,:) = log(l_channel_bands(j,:)/length(br));
            r_channel_bands(j,:) = log(r_channel_bands(j,:)/length(br));
        end
        
        diff_channel_bands = l_channel_bands - r_channel_bands;
        
        br_powers(1,:,:,i) = l_channel_bands;
        br_powers(2,:,:,i) = r_channel_bands;
        br_powers(3,:,:,i) = diff_channel_bands;
    end
    
    % to put all the powers on the same axis, save the maximum & minimum power
    ymax = max(max(max(max(br_powers))));
    ymin = min(min(min(min(br_powers))));
    
    for i = 1:length(brain_region_labels)/2
        for j = 1:5
            subfolder = fullfile(folder,band_name(j));
            if ~exist(subfolder, 'dir')
                mkdir(subfolder);
            end
            % for each frequency band, create a subplot of left, right and difference for each pair
            f = figure('visible','off');
            subplot(3,1,1);
            plot(times,squeeze(br_powers(1,j,:,i)));
            xlim([time_range(1)*miliconvert time_range(2)*miliconvert]);
            ylim([ymin ymax]);
            title(band_name(j) + ' power over time for ' + brain_region_labels(2*i-1) + ' brain region ');
            set(gca,'XMinorTick','on','YMinorTick','on')
            subplot(3,1,2);
            plot(times,squeeze(br_powers(2,j,:,i)));
            xlim([time_range(1)*miliconvert time_range(2)*miliconvert]);
            ylim([ymin ymax]);
            title(band_name(j) + ' power over time for power over time for ' + brain_region_labels(2*i) + ' brain region ');
            set(gca,'XMinorTick','on','YMinorTick','on')
            subplot(3,1,3);
            plot(times,squeeze(br_powers(3,j,:,i)));
            xlim([time_range(1)*miliconvert time_range(2)*miliconvert]);
            ylim([ymin ymax]);
            title('Difference in Left and Right ' + band_name(j) + ' power over time');
            xlabel('Time, in minutes');
            set(gca,'XMinorTick','on','YMinorTick','on')
            ylabel('Difference in log power, dB');
            plotname = fullfile(subfolder,brain_region_labels(2*i-1) + "_" + brain_region_labels(2*i));
            saveas(f, plotname + ".fig");
            saveas(f, plotname + ".png");
            close;
        end
        fprintf('Plots complete for ' + brain_region_labels(2*i-1) + ' and ' + brain_region_labels(2*i) + ' brain region\n');
    end
end

