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
fsr_timestamps = zeros(length([aligned_data(:).A0_fsr]),1);
feeltrace_data = zeros(length([aligned_data(:).feeltrace]),1);
A0_data = zeros(length([aligned_data(:).A0_fsr]),1);
A1_data = zeros(length([aligned_data(:).A1_fsr]),1);
A2_data = zeros(length([aligned_data(:).A2_fsr]),1);
A3_data = zeros(length([aligned_data(:).A3_fsr]),1);
A4_data = zeros(length([aligned_data(:).A4_fsr]),1);

fti = 1;
fsri = 1;

for k = 1:length([aligned_data(:).timestamp_ms])
  if ~isempty(aligned_data(k).feeltrace)
      feeltrace_timestamps(fti) = (k-1)/60000;
      feeltrace_data(fti) = aligned_data(k).feeltrace;
      fti = fti + 1;
  end
  if ~isempty(aligned_data(k).A0_fsr)
      fsr_timestamps(fsri) = (k-1)/60000;
      A0_data(fsri) = aligned_data(k).A0_fsr;
      A1_data(fsri) = aligned_data(k).A1_fsr;
      A2_data(fsri) = aligned_data(k).A2_fsr;
      A3_data(fsri) = aligned_data(k).A3_fsr;
      A4_data(fsri) = aligned_data(k).A4_fsr;
      fsri = fsri + 1;
  end    
end

clearvars title;
%feeltrace_data = smooth(feeltrace_data, 30);

max_ft = max(feeltrace_data);
max_keypress =  max([max(A0_data) max(A1_data) max(A2_data) max(A3_data) max(A4_data)]);
%ratio_max_keypress_over_ft = max_keypress/max_ft;
fig = figure(1);
%figure('DefaultAxesFontSize',18)
pos1 = [0.1 0.1 0.7 0.8];
subplot(6,1,1);
title(strcat("Feeltrace and keypress data for participant ", trial_number));
%plot(feeltrace_timestamps,feeltrace_data,'Color',[1 1 1],'LineWidth',4);
plot(feeltrace_timestamps,feeltrace_data,'Color',[0 0 0],'LineWidth',1.5);
axis([0 feeltrace_timestamps(fti-1) 0 max_ft]);
yticks([0 max_ft]);
yticklabels({'Relief','Stress'});
ylabel('Feeltrace');
set(gca,'FontSize',18);
set(gca,'linewidth',1);

subplot(6,1,2);
area(fsr_timestamps,A0_data,'FaceColor',[239/255 49/255 86/255], 'EdgeColor',[239/255 49/255 86/255]);
axis([0 feeltrace_timestamps(fti-1) 0 max_keypress]);
yticks([0 max_keypress]);
yticklabels({'Min','Max'});
ylabel('A0');
set(gca,'FontSize',18);
set(gca,'linewidth',1);

subplot(6,1,3);
area(fsr_timestamps,A1_data,'FaceColor',[244/255 93/255 1/255], 'EdgeColor',[244/255 93/255 1/255]);
axis([0 feeltrace_timestamps(fti-1) 0 max_keypress]);
yticks([0 max_keypress]);
yticklabels({'Min','Max'});
ylabel('A1');
set(gca,'FontSize',18);
set(gca,'linewidth',1);

subplot(6,1,4);
area(fsr_timestamps,A2_data,'FaceColor',[255/255 159/255 28/255], 'EdgeColor',[255/255 159/255 28/255]);
axis([0 feeltrace_timestamps(fti-1) 0 max_keypress]);
yticks([0 max_keypress]);
yticklabels({'Min','Max'});
ylabel('A2');
set(gca,'FontSize',18);
set(gca,'linewidth',1);

subplot(6,1,5);
area(fsr_timestamps,A3_data,'FaceColor',[86/255 188/255 3/255], 'EdgeColor',[86/255 188/255 3/255]);
axis([0 feeltrace_timestamps(fti-1) 0 max_keypress]);
yticks([0 max_keypress]);
yticklabels({'Min','Max'});
ylabel('A3');
set(gca,'FontSize',18);
set(gca,'linewidth',1);

subplot(6,1,6);
area(fsr_timestamps,A4_data,'FaceColor',[45/255 125/255 210/255], 'EdgeColor',[45/255 125/255 210/255]);
axis([0 feeltrace_timestamps(fti-1) 0 max_keypress]);
yticks([0 max_keypress]);
yticklabels({'Min','Max'});
ylabel('A4');
set(gca,'FontSize',18);
set(gca,'linewidth',1);
%plot(fsr_timestamps,A1_data/ratio,'Color',[0.2 0.2 1]);
%plot(fsr_timestamps,A2_data/ratio,'Color',[1 1 0.2]);
%plot(fsr_timestamps,A3_data/ratio,'Color',[0.2 1 1]);
%plot(fsr_timestamps,A4_data/ratio,'Color',[1 0.2 1]);
%ylabel('Intensity of keypress');
%yticks([])
%plot(feeltrace_timestamps,feeltrace_data,'Color',[0 0 0],'LineWidth',1);


%yyaxis right
%ax = get(gcf,'CurrentAxes');
%ax.YAxis(2).Color = 'black';
%plot(feeltrace_timestamps,feeltrace_data,'Color',[0 0 0]);
%yticks([0 max_ft])
%yticklabels({'Relief','Stress'})
%ylabel('Feeltrace from stres to relief')
%xlabel('Time (min)');

%pos1 = [0.8 0.1 0.2 0.8];
%hSub = subplot('Position',pos1);
%hold on;
%plot(1,nan,'Color',[0.2 1 0.2]);
%plot(1,nan,'Color',[0.2 0.2 1]);
%plot(1,nan,'Color',[1 1 0.2]);
%plot(1,nan,'Color',[0.2 1 1]);
%plot(1,nan,'Color',[1 0.2 1]);
%plot(1,nan,'Color',[0 0 0], 'LineWidth', 2);
%hold off;
%set(hSub, 'Visible', 'off');
%legend('alt (grab) key','right key','down key','left key','up key','feeltrace');
%t = title('FSR and Feeltrace data from Participant');
%gca.Ycolor = [0 0 0];
%set(gca,'YTickLabel',[]);
%yyaxis left
%ylabel('Reported stress level');
%set(gca,'YTickLabel',[]);
%title('Keypress FSR and stress-to-relief feeltrace during gameplay');


saveas(gcf,fullfile(processed_directory,['fsr_and_feeltrace-stacked' char(trial_number) '.png']));

fig.PaperUnits = 'inches';
orient(fig,'landscape')
fig.PaperPosition = [0 0 10 8];
print(fullfile(processed_directory,['fsr_and_feeltrace-large-stacked' char(trial_number)]),'-dpng','-r0');


fig.PaperUnits = 'inches';
orient(fig,'landscape')
fig.PaperPosition = [0 0 145 16];
print(fullfile(processed_directory,['fsr_and_feeltrace-long-stacked' char(trial_number)]),'-dpng','-r0');

close(f);
%clearvars definput dims hSub max_ft max_keypress pos1 prompt ratio_max_keypress_over_ft t f feeltrace_timestamps feeltrace_data fsr_timestamps A0_data A1_data A2_data A3_data A4_data k a0i fti;
