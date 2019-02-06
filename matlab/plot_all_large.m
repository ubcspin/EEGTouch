% Plots FSRs, feeltrace on interview into big printable image.

% Load directories and data.
load_globals;

MS_PER_MIN = 60000;
LONGEST_TRIAL_LENGTH_MIN = 10;

% If data to plot is not available, get it.
if ~any(ismember(fields(processed_data),{'feeltrace'}))
    feeltrace_align;
end
if ~any(ismember(fields(processed_data),{'fsr'})) 
   fsr_gameplay_align;
end
if ~any(ismember(fields(processed_data),{'interview'}))
    align_interview;
end

%% PREPARING STUFF TO PLOT
% array of ones for 1D interview plot at controlled height
interview_ones = ones(length(processed_data.interview.timestamp_ms),1);
% array of number + staggered space strings for interview x-labels
interview_nums_num = (1:length(processed_data.interview.timestamp_ms)).';
interview_nums = arrayfun(@(x) strcat(num2str(x),convertCharsToStrings(blanks(mod(x,3)*2))), interview_nums_num,'UniformOutput',false);

max_feeltrace = max(processed_data.feeltrace.joystick);
max_keypress =  max([max(processed_data.fsr.A0) max(processed_data.fsr.A1) max(processed_data.fsr.A2) max(processed_data.fsr.A3) max(processed_data.fsr.A4)]);
ratio = max_keypress/max_feeltrace;

%% LET'S GET PLOTTING
clf;
fig = figure(1);

%% FIRST SUBPLOT: A0
 subplot(29,1,[1 2 3 4 5]);
 hold on;
 grid on;
 % area plot the FSR
 area(processed_data.fsr.timestamp_ms/60000,processed_data.fsr.A0/ratio,'FaceColor',[239/255 49/255 86/255], 'EdgeColor',[239/255 49/255 86/255]);
 % line plot the feeltrace
 plot(processed_data.feeltrace.timestamp_ms/60000,processed_data.feeltrace.joystick,'Color',[0 0 0],'LineWidth',3.5);
 ax = gca;
 ax.XGrid = 'off';
 ylim([0 max_feeltrace]);
 yticks([0 max_feeltrace/2 max_feeltrace]);
 yticklabels({'','A0','          Stress'});
 ytickangle(90);
 xlim([0 LONGEST_TRIAL_LENGTH_MIN]);
 xticks(0 : 0.25 : ceil(processed_data.fsr.timestamp_ms(end)));
 xticklabels([]);
 set(gca,'FontSize',30);
 set(gca,'linewidth',1);
hold off;

%% SUBPLOT A1
subplot(29,1,[6 7 8 9 10]);
hold on;
grid on;
area(processed_data.fsr.timestamp_ms/60000,processed_data.fsr.A1/ratio,'FaceColor',[244/255 93/255 1/255], 'EdgeColor',[244/255 93/255 1/255]);
plot(processed_data.feeltrace.timestamp_ms/60000,processed_data.feeltrace.joystick,'Color',[0 0 0],'LineWidth',3.5);
ax = gca;
ax.XGrid = 'off';
ylim([0 max_feeltrace]);
yticks([0 max_feeltrace/2 max_feeltrace]);
yticklabels({'','A1',''});
ytickangle(90);
xlim([0 LONGEST_TRIAL_LENGTH_MIN]);
xticks(0 : 0.25 : ceil(processed_data.fsr.timestamp_ms(end)));
xticklabels([]);
set(gca,'FontSize',30);
set(gca,'linewidth',1);
hold off;

%% SUBPLOT A2
subplot(29,1,[11 12 13 14 15]);
hold on;
grid on;
area(processed_data.fsr.timestamp_ms/60000,processed_data.fsr.A2/ratio,'FaceColor',[255/255 159/255 28/255], 'EdgeColor',[255/255 159/255 28/255]);
plot(processed_data.feeltrace.timestamp_ms/60000,processed_data.feeltrace.joystick,'Color',[0 0 0],'LineWidth',3.5);
ax = gca;
ax.XGrid = 'off';
ylim([0 max_feeltrace]);
yticks([0 max_feeltrace/2 max_feeltrace]);
yticklabels({'','A2',''});
ytickangle(90);
ylabel(strcat("Participant ", trial_number));
xlim([0 LONGEST_TRIAL_LENGTH_MIN]);
xticks(0 : 0.25 : ceil(processed_data.fsr.timestamp_ms(end)));
xticklabels([]);
set(gca,'FontSize',30);
set(gca,'linewidth',1);
hold off;

%% SUBPLOT A3
subplot(29,1,[16 17 18 19 20]);
hold on;
grid on;
area(processed_data.fsr.timestamp_ms/60000,processed_data.fsr.A3/ratio,'FaceColor',[86/255 188/255 3/255], 'EdgeColor',[86/255 188/255 3/255]);
plot(processed_data.feeltrace.timestamp_ms/60000,processed_data.feeltrace.joystick,'Color',[0 0 0],'LineWidth',3.5);
ax = gca;
ax.XGrid = 'off';
ylim([0 max_feeltrace]);
yticks([0 max_feeltrace/2 max_feeltrace]);
yticklabels({'','A3',''});
ytickangle(90);
xlim([0 LONGEST_TRIAL_LENGTH_MIN]);
xticks(0 : 0.25 : ceil(processed_data.fsr.timestamp_ms(end)/60000));
xticklabels([]);
set(gca,'FontSize',30);
set(gca,'linewidth',1);
hold off;

%% SUBPLOT A4
subplot(29,1,[21 22 23 24 25]);
hold on;
grid on;
area(processed_data.fsr.timestamp_ms/60000,processed_data.fsr.A4/ratio,'FaceColor',[45/255 125/255 210/255], 'EdgeColor',[45/255 125/255 210/255]);
plot(processed_data.feeltrace.timestamp_ms/60000,processed_data.feeltrace.joystick,'Color',[0 0 0],'LineWidth',3.5);
ax = gca;
ax.XGrid = 'off';
ylim([0 max_feeltrace]);
yticks([0 max_feeltrace/2 max_feeltrace]);
yticklabels({'Relief          ','A4',""});
ytickangle(90);
starttick = max(floor(min(processed_data.fsr.timestamp_ms(1)/60000, processed_data.feeltrace.timestamp_ms(1)/60000)),0.25);
xlim([0 LONGEST_TRIAL_LENGTH_MIN]);
xticks(0 : 0.25 : ceil(processed_data.fsr.timestamp_ms(end)/60000));
xticklabels(vertcat(strings(1,starttick/0.25), datestr(datetime((starttick/24/60:1/24/60/60*15:1/24/60*ceil(processed_data.fsr.timestamp_ms(end)/60000)),'ConvertFrom','datenum'),'MM:SS')));
xtickangle(90); 
set(gca,'FontSize',30);
set(gca,'linewidth',1);
hold off;

%% SUBPLOT INTERVIEW
subplot(29,1,29);
scatter(processed_data.interview.timestamp_ms/60000,interview_ones, 17, 'black', '*');
ylim([0 2]);
yticks([]);
xlim([0 LONGEST_TRIAL_LENGTH_MIN]);
xticks(processed_data.interview.timestamp_ms/60000);
xticklabels(interview_nums);
xtickangle(90);
ax = gca;
ax.TickLength = [.001 .001];
set(gca,'FontSize',15);
xstring = join(repmat(strcat("                                                            P", trial_number),1,32));
xlabel(xstring,'FontSize', 11);

%% PRINT AND SAVE
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 110 16];
print(fullfile(processed_directory,['fsr_and_feeltrace-over' char(trial_number)]),'-dpng','-r0');

clearvars ax interview_nums interview_nums_num interview_ones LONGEST_TRIAL_LENGTH_MIN max_feeltrace max_keypress MS_PER_MIN ratio starttick xstring;