f = waitbar(0.9,'Plotting FSR and feeltrace data','Name','Data Processing');
clf('reset');
clearvars fig;
hold off;
if ~exist('trial_directory') 
    trial_directory = uigetdir(path,"Select directory containg raw data from the trial");
end
if ~exist('processed_directory')
    processed_directory = uigetdir(path,"Select directory to save processed data in.");
end
if ~exist('trial_number')
    prompt = {'Enter trial number:'};
        title = 'Trial number';
        dims = [1 35];
        definput = {'0'};
        trial_number = inputdlg(prompt,title,dims,definput);
end
feeltrace_timestamps = zeros(length([aligned_data(:).feeltrace]),1);
feeltrace_data = zeros(length([aligned_data(:).feeltrace]),1);

fti = 1;

for k = 1:length([aligned_data(:).timestamp_ms])
  if ~isempty(aligned_data(k).feeltrace)
      feeltrace_timestamps(fti) = (k-1)/60000;
      feeltrace_data(fti) = aligned_data(k).feeltrace;
      fti = fti + 1;
  end
  end

clearvars title;
%feeltrace_data = smooth(feeltrace_data, 30);

max_ft = max(feeltrace_data);
max_keypress =  max([max(A0_data) max(A1_data) max(A2_data) max(A3_data) max(A4_data)]);
fig = figure(1);
title(strcat("Feeltrace and keypress data for participant ", trial_number));
plot(feeltrace_timestamps,feeltrace_data,'Color',[0 0 0],'LineWidth',2.5);
axis([0 feeltrace_timestamps(fti-1) 0 max_ft]);
yticks([0 max_ft]);
yticklabels({'Relief','Stress'});
ylabel('Feeltrace');
firsttime = feeltrace_timestamps(1);
starttick = floor(firsttime) + floor( (firsttime-floor(firsttime))/0.25) * 0.25;
xticks(starttick : 0.25 : floor(feeltrace_timestamps(fti-1)));
xticklabels(datestr(datetime((starttick/24/60:1/24/60/60*15:1/24/60*floor(feeltrace_timestamps(fti-1))),'ConvertFrom','datenum'),'MM:SS'));
set(gca,'FontSize',30);
set(gca,'linewidth',1);




fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 143 16];
print(fullfile(processed_directory,['fsr_and_feeltrace-long-ftonly' char(trial_number)]),'-dpng','-r0');
close(f);
clf('reset');
clearvars fig;
clearvars firsttime fsri xtick_arr starttick definput dims hSub max_ft max_keypress pos1 prompt ratio_max_keypress_over_ft t f feeltrace_timestamps feeltrace_data fsr_timestamps A0_data A1_data A2_data A3_data A4_data k a0i fti;
