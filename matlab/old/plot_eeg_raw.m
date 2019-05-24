% plots 64 channels of eeg data with standard graph colors

load_globals;

if exist('processed_data','var') && ~any(ismember(fields(processed_data),{'eeg'}))
   eeg_align; 
end

eeg = processed_data.eeg.eeg;
ms = processed_data.eeg.timestamp_ms;
min = ms/60000;
hold on;
k = 1;
NUM_CHANNELS = 64;
while k < NUM_CHANNELS
    plot(min, eeg(:,k));
    k = k+1;
end
hold off;

xlabel('Time (min)');
title(['64-channel EEG potentials during gameplay for trial ' trial_number]);
saveas(gcf,fullfile(processed_directory,'eeg.png'));

clearvars eeg k min ms NUM_CHANNELS;