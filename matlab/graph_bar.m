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

clearvars title;
feeltrace_data = smooth(feeltrace_data, 101);

A0_data = smooth(A0_data, 30);
A1_data = smooth(A1_data, 30);
A2_data = smooth(A2_data, 30);
A3_data = smooth(A3_data, 30);
A4_data = smooth(A4_data, 30);

max_ft = max(feeltrace_data);
ratio = max([max(A0_data) max(A1_data) max(A2_data) max(A3_data) max(A4_data)])/max(feeltrace_data);
fig = figure(1);
pos1 = [0.1 0.1 0.7 0.8];
subplot('Position',pos1);
title(strcat("FSR and Feeltrace data for participant ", trial_number));
hold on;
%%%set(figure,'defaultAxesColorOrder',[[0 0 0]; [0 0 0]]);
area(fsr_timestamps,A0_data/ratio,'FaceColor',[0 1 0], 'EdgeColor', [0 1 0], 'FaceAlpha', 0.5, 'EdgeAlpha', 0.5);
area(fsr_timestamps,A1_data/ratio,'FaceColor',[0 0 1], 'EdgeColor',[0 0 1], 'FaceAlpha', 0.5, 'EdgeAlpha', 0.5);
area(fsr_timestamps,A2_data/ratio,'FaceColor',[1 1 0], 'EdgeColor',[1 1 0], 'FaceAlpha', 0.5, 'EdgeAlpha', 0.5);
area(fsr_timestamps,A3_data/ratio,'FaceColor',[0 1 1], 'EdgeColor',[0 1 1], 'FaceAlpha', 0.5, 'EdgeAlpha', 0.5);
area(fsr_timestamps,A4_data/ratio,'FaceColor',[1 0 1], 'EdgeColor',[1 0 1], 'FaceAlpha', 0.5, 'EdgeAlpha', 0.5);
ylabel('Intensity of keypress');
%yticks([])
%%%plot(feeltrace_timestamps,feeltrace_data,'Color',[0 0 0],'LineWidth',1);
%plot(feeltrace_timestamps,feeltrace_data,'Color',[1 1 1],'LineWidth',6.5);
%plot(feeltrace_timestamps,feeltrace_data,'Color',[0 0 0],'LineWidth',3);
%hold off;

yyaxis right
ax = get(gcf,'CurrentAxes');
ax.YAxis(2).Color = 'black';
%plot(feeltrace_timestamps,feeltrace_data,'Color',[0 0 0]);
yticks([0 max_ft])
yticklabels({'Relief','Stress'})
ylabel('Feeltrace from stres to relief')
xlabel('Time (min)');

pos1 = [0.8 0.1 0.2 0.8];
hSub = subplot('Position',pos1);
hold on;
plot(1,nan,'Color',[0.2 1 0.2]);
plot(1,nan,'Color',[0.2 0.2 1]);
plot(1,nan,'Color',[1 1 0.2]);
plot(1,nan,'Color',[0.2 1 1]);
plot(1,nan,'Color',[1 0.2 1]);
plot(1,nan,'Color',[0 0 0], 'LineWidth', 2);
hold off;
set(hSub, 'Visible', 'off');
legend('alt (grab) key','right key','down key','left key','up key','feeltrace');
t = title('FSR and Feeltrace data from Participant');
%gca.Ycolor = [0 0 0];
%set(gca,'YTickLabel',[]);
%yyaxis left
%ylabel('Reported stress level');
%set(gca,'YTickLabel',[]);
%title('Keypress FSR and stress-to-relief feeltrace during gameplay');


saveas(gcf,fullfile(processed_directory,['fsr_and_feeltrace' char(trial_number) '.png']));

fig.PaperUnits = 'inches';
orient(fig,'landscape')
fig.PaperPosition = [0 0 10 8];
print(fullfile(processed_directory,['fsr_and_feeltrace-large' char(trial_number)]),'-dpng','-r0');

close(f);
%clf('reset');
%clearvars f feeltrace_timestamps feeltrace_data fsr_timestamps A0_data A1_data A2_data A3_data A4_data k a0i fti;
