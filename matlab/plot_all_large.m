%f = waitbar(0.9,'Plotting FSR and feeltrace data','Name','Data Processing');
clf('reset');
clearvars fig;
hold off;
% if ~exist('trial_directory') 
%     trial_directory = uigetdir(path,"Select directory containg raw data from the trial");
% end
if ~exist('processed_directory')
    processed_directory = uigetdir(path,"Select directory to save processed data in.");
end
if ~exist('processed_data') || ~exist('processed_data.scalars') || ~exist('processed_data.scalars.trial_number')
    prompt = {'Enter trial number:'};
        title = 'Trial number';
        dims = [1 35];
        definput = {'0'};
        trial_number = inputdlg(prompt,title,dims,definput);
        processed_data.scalars.trial_number = trial_number
end
%feeltrace_timestamps = zeros(length([aligned_data(:).feeltrace]),1);
%fsr_timestamps = zeros(length([aligned_data(:).A0_fsr]),1);
%feeltrace_data = zeros(length([aligned_data(:).feeltrace]),1);
%A0_data = zeros(length([aligned_data(:).A0_fsr]),1);
%A1_data = zeros(length([aligned_data(:).A1_fsr]),1);
%A2_data = zeros(length([aligned_data(:).A2_fsr]),1);
%A3_data = zeros(length([aligned_data(:).A3_fsr]),1);
%A4_data = zeros(length([aligned_data(:).A4_fsr]),1);
%interview_times = zeros(200,1);

feeltrace_timestamps = processed_data.feeltrace.timestamp_ms/60000;
fsr_timestamps = processed_data.fsr.timestamp_ms/60000;
feeltrace_data = processed_data.feeltrace.joystick;
A0_data = processed_data.fsr.A0;
A1_data = processed_data.fsr.A1;
A2_data = processed_data.fsr.A2;
A3_data = processed_data.fsr.A3;
A4_data = processed_data.fsr.A4;
interview_times = processed_data.interview.timestamp_ms/60000;


% fti = 1;
% fsri = 1;
% invui = 1;
% 
% for k = 1:length([aligned_data(:).timestamp_ms])
%   if ~isempty(aligned_data(k).feeltrace)
%       feeltrace_timestamps(fti) = (k-1)/60000;
%       feeltrace_data(fti) = aligned_data(k).feeltrace;
%       fti = fti + 1;
%   end
%   if ~isempty(aligned_data(k).A0_fsr)
%       fsr_timestamps(fsri) = (k-1)/60000;
%       A0_data(fsri) = aligned_data(k).A0_fsr;
%       A1_data(fsri) = aligned_data(k).A1_fsr;
%       A2_data(fsri) = aligned_data(k).A2_fsr;
%       A3_data(fsri) = aligned_data(k).A3_fsr;
%       A4_data(fsri) = aligned_data(k).A4_fsr;
%       fsri = fsri + 1;
%   end
%   if ~isempty(aligned_data(k).interview)
%       interview_times(invui) = (k-1)/60000;
%       invui = invui + 1;
%   end
% end
% 
%interview_times = interview_times(2:find(interview_times==0,1,'first')-1);
interview_ones = ones(length(interview_times),1);
interview_nums_num = (1:length(interview_times)).';
interview_nums = arrayfun(@(x) strcat(num2str(x),convertCharsToStrings(blanks(mod(x,3)*2))), interview_nums_num,'UniformOutput',false);
% 
% space_strings = repmat(["";"  ";"    "],length(interview_times),1);
% space_strings = space_strings(1:length(interview_times));
% interview_nums = (horzcat(space_strings, arrayfun(@num2str, interview_nums_num, 'UniformOutput', false)));


clearvars title;
%feeltrace_data = smooth(feeltrace_data, 30);

max_ft = max(feeltrace_data);
max_keypress =  max([max(A0_data) max(A1_data) max(A2_data) max(A3_data) max(A4_data)]);
ratio_max_ft_over_keypress = max_ft/max_keypress;
ratio = max([max(A0_data) max(A1_data) max(A2_data) max(A3_data) max(A4_data)])/max(feeltrace_data);
%title(strcat("Feeltrace and keypress data for participant ", trial_number));
fig = figure(1);

%length of longest trial
max_all = 22;

subplot(29,1,[1 2 3 4 5]);
hold on;
grid on;
area(fsr_timestamps,A0_data/ratio,'FaceColor',[239/255 49/255 86/255], 'EdgeColor',[239/255 49/255 86/255]);
plot(feeltrace_timestamps,feeltrace_data,'Color',[0 0 0],'LineWidth',3.5);
ax = gca;
ax.XGrid = 'off';
ylim([0 max_ft]);
yticks([0 max_ft/2 max_ft]);
yticklabels({'','A0','          Stress'});
ytickangle(90);
xlim([0 max_all]);
xticks(0 : 0.25 : ceil(fsr_timestamps(end)));
xticklabels([]);
set(gca,'FontSize',30);
set(gca,'linewidth',1);
hold off;

subplot(29,1,[6 7 8 9 10]);
hold on;
grid on;
area(fsr_timestamps,A1_data/ratio,'FaceColor',[244/255 93/255 1/255], 'EdgeColor',[244/255 93/255 1/255]);
plot(feeltrace_timestamps,feeltrace_data,'Color',[0 0 0],'LineWidth',3.5);
ax = gca;
ax.XGrid = 'off';
ylim([0 max_ft]);
yticks([0 max_ft/2 max_ft]);
yticklabels({'','A1',''});
ytickangle(90);
xlim([0 max_all]);
xticks(0 : 0.25 : ceil(fsr_timestamps(end)));
xticklabels([]);
set(gca,'FontSize',30);
set(gca,'linewidth',1);
hold off;

subplot(29,1,[11 12 13 14 15]);
hold on;
grid on;
area(fsr_timestamps,A2_data/ratio,'FaceColor',[255/255 159/255 28/255], 'EdgeColor',[255/255 159/255 28/255]);
plot(feeltrace_timestamps,feeltrace_data,'Color',[0 0 0],'LineWidth',3.5);
ax = gca;
ax.XGrid = 'off';
ylim([0 max_ft]);
yticks([0 max_ft/2 max_ft]);
yticklabels({'','A2',''});
ytickangle(90);
ylabel(strcat("Participant ", trial_number));
xlim([0 max_all]);
xticks(0 : 0.25 : ceil(fsr_timestamps(end)));
xticklabels([]);
set(gca,'FontSize',30);
set(gca,'linewidth',1);
hold off;

subplot(29,1,[16 17 18 19 20]);
hold on;
grid on;
area(fsr_timestamps,A3_data/ratio,'FaceColor',[86/255 188/255 3/255], 'EdgeColor',[86/255 188/255 3/255]);
plot(feeltrace_timestamps,feeltrace_data,'Color',[0 0 0],'LineWidth',3.5);
ax = gca;
ax.XGrid = 'off';
ylim([0 max_ft]);
yticks([0 max_ft/2 max_ft]);
yticklabels({'','A3',''});
ytickangle(90);
xlim([0 max_all]);
xticks(0 : 0.25 : ceil(fsr_timestamps(end)));
xticklabels([]);
set(gca,'FontSize',30);
set(gca,'linewidth',1);
hold off;

subplot(29,1,[21 22 23 24 25]);
hold on;
grid on;
area(fsr_timestamps,A4_data/ratio,'FaceColor',[45/255 125/255 210/255], 'EdgeColor',[45/255 125/255 210/255]);
plot(feeltrace_timestamps,feeltrace_data,'Color',[0 0 0],'LineWidth',3.5);
ax = gca;
ax.XGrid = 'off';
ylim([0 max_ft]);
yticks([0 max_ft/2 max_ft]);
yticklabels({'Relief          ','A4',""});
ytickangle(90);
starttick = max(floor(min(fsr_timestamps(1), feeltrace_timestamps(1))),0.25);
xlim([0 max_all]);
xticks(0 : 0.25 : ceil(fsr_timestamps(end)));
xticklabels(vertcat(strings(1,starttick/0.25), datestr(datetime((starttick/24/60:1/24/60/60*15:1/24/60*ceil(fsr_timestamps(end))),'ConvertFrom','datenum'),'MM:SS')));
xtickangle(90); 
set(gca,'FontSize',30);
set(gca,'linewidth',1);
hold off;

subplot(29,1,29);
scatter(interview_times,interview_ones, 17, 'black', '*');
ylim([0 2]);
yticks([]);
xlim([0 max_all]);
xticks(interview_times);
xticklabels(interview_nums);
xtickangle(90);
ax = gca;
ax.TickLength = [.001 .001];
set(gca,'FontSize',15);
xstring = join(repmat(strcat("                                                            P", trial_number),1,32));
xlabel(xstring,'FontSize', 11);





fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 110 16];
print(fullfile(processed_directory,['fsr_and_feeltrace-over' char(trial_number)]),'-dpng','-r0');
%close(f);
%clf('reset');
%clearvars fig;
%clearvars firsttime fsri xtick_arr starttick definput dims hSub max_ft max_keypress pos1 prompt ratio_max_keypress_over_ft t f feeltrace_timestamps feeltrace_data fsr_timestamps A0_data A1_data A2_data A3_data A4_data k a0i fti;
