f = waitbar(0.9,'Plotting FSR and feeltrace data','Name','Data Processing');
hold off;
clf('reset');
if ~exist('trial_directory') 
    trial_directory = uigetdir(path,"Select directory containg raw data from the trial");
end
if ~exist('processed_director')
    processed_directory = uigetdir(path,"Select directory to save processed data in.");
end
feeltrace_timestamps = zeros(length([aligned_data(:).feeltrace]),1);
fsr_timestamps = zeros(length([aligned_data(:).A0_fsr]),1);
feeltrace_data = zeros(length([aligned_data(:).feeltrace]),1);
A0_data = zeros(length([aligned_data(:).A0_fsr]),1);
A1_data = zeros(length([aligned_data(:).A1_fsr]),1);
A2_data = zeros(length([aligned_data(:).A2_fsr]),1);
A3_data = zeros(length([aligned_data(:).A3_fsr]),1);
A4_data = zeros(length([aligned_data(:).A4_fsr]),1);

fti = 1;
a0i = 1;

for k = 1:length([aligned_data(:).timestamp_ms])
  if ~isempty(aligned_data(k).feeltrace)
      feeltrace_timestamps(fti) = (k-1)/60000;
      feeltrace_data(fti) = aligned_data(k).feeltrace;
      fti = fti + 1;
  end
  if ~isempty(aligned_data(k).A0_fsr)
      fsr_timestamps(a0i) = (k-1)/60000;
      A0_data(a0i) = aligned_data(k).A0_fsr;
      A1_data(a0i) = aligned_data(k).A1_fsr;
      A2_data(a0i) = aligned_data(k).A2_fsr;
      A3_data(a0i) = aligned_data(k).A3_fsr;
      A4_data(a0i) = aligned_data(k).A4_fsr;
      a0i = a0i + 1;
  end    
end

hold on;
plot(fsr_timestamps,A0_data/3.5,'Color',[0 1 0]);
plot(fsr_timestamps,A1_data/3.5,'Color',[0 0 1]);
plot(fsr_timestamps,A2_data/3.5,'Color',[1 1 0]);
plot(fsr_timestamps,A3_data/3.5,'Color',[0 1 1]);
plot(fsr_timestamps,A4_data/3.5,'Color',[1 0 1]);
plot(feeltrace_timestamps,feeltrace_data,'Color',[0 0 0],'LineWidth',0.8);

legend('alt (grab) key','right key','down key','left key','up key','feeltrace');
xlabel('Time (min)');
ylabel('Intensity of keypress');
set(gca,'YTickLabel',[]);
%yyaxis left
%ylabel('Reported stress level');
%set(gca,'YTickLabel',[]);
%title('Keypress FSR and stress-to-relief feeltrace during gameplay');
hold off;


saveas(gcf,fullfile(processed_directory,'fsr_and_feeltrace.png'));

close(f);
%clearvars f feeltrace_timestamps feeltrace_data fsr_timestamps A0_data A1_data A2_data A3_data A4_data k a0i fti;
