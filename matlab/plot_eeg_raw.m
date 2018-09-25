%plots 64 channels of eeg data with random colors, for some reason
f = waitbar(0.3,'Plotting EEG data','Name','Data Processing');

eeg_to_plot = eeg_data_synced(2:end,:);

en = length(eeg_to_plot(1,:))-100000;
ax = ones(1,length(eeg_to_plot(1,:)))/1000;
ax = cumsum(ax);
colors = rand(64,3);
hold on;
k = 1;
while k < 20
    plot(ax(1:en),eeg_to_plot(k,1:en),'Color',colors(k,:));
    k = k+1;
end
hold off;

xlabel('Time (min)');
ylabel('microvolts');
%title('64-channel EEG potentials during gameplay');
hold off;
saveas(gcf,'eeg.png')

close(f);
clearvars f en ax colors k eeg_to_plot eeg_data_synced;