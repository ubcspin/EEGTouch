% Plots FSRs, feeltrace on interview into big printable image.

%TODO: make this a function
%TODO: refactor helpers

% Load directories and data.
load_globals;
clf;

MS_PER_MIN = 60000;
LONGEST_TRIAL_LENGTH_MIN = 22;

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

%% FIRST SUBPLOT: feeltrace and calibrated words

% plot in sections 1-12 of 29-section grid
subplot(29,1,[2 3 4 5 6 7 8 9 10 11 12]);
hold on;
grid on;

% %plot fsrs
max_fsr = max([processed_data.fsr.A0  processed_data.fsr.A1  processed_data.fsr.A2 processed_data.fsr.A3 processed_data.fsr.A4],[],2);
area(processed_data.fsr.timestamp_ms/60000, max_fsr/1023*20, 'FaceColor',[0.9 0.9 0.9],'EdgeColor',[0.9 0.9 0.9]);
% line plot the feeltrace
max_joystick = max(processed_data.feeltrace.joystick);
plot(processed_data.feeltrace.timestamp_ms/60000,processed_data.feeltrace.joystick/max_joystick*20,'Color',[21/255 104/255 237/255],'LineWidth',2);
% line plot the calibrated words
plot(processed_data.calibrated_words.timestamp_ms/60000, processed_data.calibrated_words.calibrated_values+10, 'Color', [255/255 129/255 0/255], 'LineWidth', 2)
% scatter plot the calibrated words
scatter(processed_data.calibrated_words.timestamp_ms/60000, processed_data.calibrated_words.calibrated_values+10,5,'Marker','*','LineWidth',2,'MarkerEdgeColor',[255/255 129/255 0/255]);
% set positions for calibrated words text
x_textpos = processed_data.calibrated_words.timestamp_ms/60000;
y_textpos = processed_data.calibrated_words.calibrated_values+10;
% plot calibrated words text
text_g = text(x_textpos, y_textpos, cellstr(processed_data.calibrated_words.emotion_words));

% set text angle, weight, size
for i = 1:length(processed_data.calibrated_words.timestamp_ms)
    text_g(i).Rotation = 90;
    text_g(i).FontWeight = 'bold';
    text_g(i).FontSize = 18;
end

% set range from -10 to 10
ylim([0,20]);
% y ticks at maximum, minimum, middle
yticks([0,10,20]);
% label direction of y axis
%yticklabels(["Relieved" "" "Stressed"]);
emo_ylab = 'Reported emotion';
emo_ylab = [emo_ylab newline 'Relieved                                             Stressed'];
ylabel(emo_ylab,'FontSize',12);
yticklabels([]);
%ytickangle(90);
% set domain to longest trial length for equivalent figure size
xlim([0 LONGEST_TRIAL_LENGTH_MIN]);
% x ticks every 15 seconds
xticks(0 : 0.25 : ceil(processed_data.fsr.timestamp_ms(end)));
xticklabels([]);
xtickangle(90); 
ax = gca;
ax.XGrid = 'on';
 set(ax,'FontSize',15);
 set(ax,'linewidth',1);
 
yyaxis right
ax = get(gcf,'CurrentAxes');
ax.YAxis(2).Color = 'black';
ylabel('Keypress intensity','FontSize',15);
ytickangle(90);
%ylabelangle(90);
yticks([0 20]);
ylim([0,20]);
yticklabels(["Min" "Max"]);
ax = gca;
set(ax,'FontSize',15);
hold off;

%% SUBPLOT 2: interview text

subplot(29,1,[13 14 15 16 17]);
hold on;
grid on;
x_textpos = processed_data.interview.timestamp_ms/60000;
y_textpos = zeros(length(processed_data.interview.timestamp_ms),1);
j = 2;
for i = 1:length(processed_data.interview.timestamp_ms)
    while processed_data.feeltrace.timestamp_ms(j) < processed_data.interview.timestamp_ms(i)
        j = j+1;
    end
    %y_textpos(i) = processed_data.feeltrace.joystick(j-1)/225;
end
haspal = find(strcmp(listfonts, 'Palatino'));
hastimes = find(strcmp(listfonts, 'Times New Roman'));


if hastimes
    wrapped_text = arrayfun(@(c) textwrap(c,30), processed_data.interview.label,'UniformOutput',false);
    text_g = text(x_textpos, y_textpos, wrapped_text,'Margin',0.001,'BackgroundColor',[1 1 1],'FontName','Times New Roman');
elseif haspal
    wrapped_text = arrayfun(@(c) textwrap(c,30), processed_data.interview.label,'UniformOutput',false);
    text_g = text(x_textpos, y_textpos, wrapped_text,'Margin',0.001,'BackgroundColor',[1 1 1],'FontName','Palatino');
else
    wrapped_text = arrayfun(@(c) textwrap(c,30), processed_data.interview.label,'UniformOutput',false);
    text_g = text(x_textpos, y_textpos, wrapped_text,'Margin',0.001,'BackgroundColor',[1 1 1]);
end

for i = 1:length(processed_data.interview.timestamp_ms)
    text_g(i).Rotation = 90;
    %text_g(i).FontWeight = 'bold';
    text_g(i).FontSize = 13;
end

% if hastimes
%     ylabel('Interview','FontSize',15,'FontName','Times New Roman');
% elseif haspal
%     ylabel('Interview','FontSize',15,'FontName','Palatino');
% else
    ylabel('Interview','FontSize',15);
% end

yticks([]);
xlim([0 LONGEST_TRIAL_LENGTH_MIN]);
xticks(0 : 0.25 : ceil(processed_data.fsr.timestamp_ms(end)));
xticklabels([]);
xtickangle(90); 

hold off;

%% SUBPLOT 3: event labels
subplot(29,1,[18 19 20 21 22]);
hold on;
grid on;


ytickangle(90);
%ylabelangle(90);
%yticks([0 1 2]);
%ylim([0,20]);
yticks([]);
%yticklabels(["Game" "Sound" "Character"]);
ax = gca;
set(ax,'FontSize',12);
grid off;
% game events
x_textpos = vertcat(7/60, processed_data.events.game.timestamp_ms/60000);
y_textpos = zeros(length(processed_data.events.game.timestamp_ms)+1,1);
wrapped_text = char(processed_data.events.game.label);
wrapped_text = wrapped_text(:,1:9);
wrapped_text = vertcat('GAME     ',wrapped_text);
%wrapped_text = arrayfun(@(c) extractBefore(c,min(strlength(c),12)+1), processed_data.events.game.label,'UniformOutput',false);
%text_g = text(x_textpos, y_textpos, wrapped_text);
if hastimes
    text_g = text(x_textpos, y_textpos, wrapped_text,'Color',[0 0 0],'FontName','Times New Roman');
elseif haspal
    text_g = text(x_textpos, y_textpos, wrapped_text,'Color',[0 0 0],'FontName','Palatino');
else
    text_g = text(x_textpos, y_textpos, wrapped_text,'Color',[0 0 0]);
end
for i = 1:length(processed_data.events.game.timestamp_ms)
    text_g(i).Rotation = 90;
    %text_g(i).FontWeight = 'bold';
    text_g(i).FontSize = 12;
end

% sound events
x_textpos = vertcat(7/60,processed_data.events.sound.timestamp_ms/60000);
y_textpos = ones(length(processed_data.events.sound.timestamp_ms)+1,1);
wrapped_text = char(processed_data.events.sound.label);
wrapped_text = wrapped_text(:,1:9);
wrapped_text = vertcat('SOUND    ',wrapped_text);

%wrapped_text = arrayfun(@(c) extractBefore(c,min(strlength(c),12)+1), processed_data.events.sound.label,'UniformOutput',false);
%text_s = text(x_textpos, y_textpos, wrapped_text,'Color',[124/255 10/255 2/255],'Margin',0.5);
if hastimes
    text_s = text(x_textpos, y_textpos, wrapped_text,'Color',[124/255 10/255 2/255],'FontName','Times New Roman');
elseif haspal
    text_s = text(x_textpos, y_textpos, wrapped_text,'Color',[124/255 10/255 2/255],'FontName','Palatino');
else
    text_s = text(x_textpos, y_textpos, wrapped_text,'Color',[124/255 10/255 2/255]);
end
for i = 1:length(processed_data.events.sound.timestamp_ms)
    text_s(i).Rotation = 90;
    %text_s(i).FontWeight = 'bold';
    text_s(i).FontSize = 12;
end

% character events
x_textpos = vertcat(7/60,processed_data.events.character.timestamp_ms/60000);
y_textpos = ones(length(processed_data.events.character.timestamp_ms)+1,1)*2;
wrapped_text = char(processed_data.events.character.label);
wrapped_text = wrapped_text(:,1:9);
wrapped_text = vertcat('CHAR     ',wrapped_text);
%arrayfun(@(c) extractBefore(c,min(strlength(c),12)+1), processed_data.events.character.label,'UniformOutput',false);

if hastimes
    text_c = text(x_textpos, y_textpos, wrapped_text,'Color',[17/255 30/255 108/255],'FontName','Times New Roman');
elseif haspal
    text_c = text(x_textpos, y_textpos, wrapped_text,'Color',[17/255 30/255 108/255],'FontName','Palatino');
else
    text_c = text(x_textpos, y_textpos, wrapped_text,'Color',[17/255 30/255 108/255]);
end
for i = 1:length(processed_data.events.character.timestamp_ms)
    text_c(i).Rotation = 90;
    %text_c(i).FontWeight = 'bold';
    text_c(i).FontSize = 12;
end

%([]);

ylim([0 3]);
xlim([0 LONGEST_TRIAL_LENGTH_MIN]);
xticks(0 : 0.25 : ceil(processed_data.fsr.timestamp_ms(end)));
xticklabels([]);

% if hastimes
%     ylabel('Events','FontSize',15,'FontName','Times New Roman');
% elseif haspal
%     ylabel('Events','FontSize',15,'FontName','Palatino');
% else
    ylabel('Events','FontSize',15);
%end


 %% SUBPLOT 4: frames
subplot(29,1,[23 24 25 26 27]);
hold on;
grid on;
for i = 1:length(temp_movie)
    image([(i-1)/4 i/4],[0 1], imrotate(temp_movie(i).cdata,90));
end

yticks([]);
xlim([0 LONGEST_TRIAL_LENGTH_MIN]);
xticks(0 : 0.25 : ceil(processed_data.fsr.timestamp_ms(end)));
xticklabels([]);
%starttick = 0.25;
%xticklabels(vertcat(strings(1,starttick/0.25), datestr(datetime((starttick/24/60:1/24/60/60*15:1/24/60*ceil(processed_data.feeltrace.timestamp_ms(end)/60000)),'ConvertFrom','datenum'),'MM:SS')));
%xtickangle(90); 
%ax = gca;
%ax.XGrid = 'on';
% set(ax,'FontSize',30);
% set(ax,'linewidth',1);
%hold off;

%% SUBPLOT 5: sceneset

subplot(29,1,[28 29]);
hold on;
grid off;

colors = [[0, 0.4470, 0.7410]];
colors = [colors; 	[0.8500, 0.3250, 0.0980]];
colors = [colors; 	[0.9290, 0.6940, 0.1250]];
colors = [colors;   [0.4940, 0.1840, 0.5560]];
colors = [colors; 	[0.4660, 0.6740, 0.1880]];
colors = [colors; 	[0.3010, 0.7450, 0.9330]];
colors = [colors; 	[0.6350, 0.0780, 0.1840]];
colors = [colors; 	[0, 0, 1]];
colors = [colors; 	[1, 0, 0]];
colors = [colors; 	[0.75, 0.75, 0]];
colors = [colors; 	[0.25, 0.25, 0.25]];


times = [scenes_cell{:,9}]';
isstart = [scenes_cell{:,3}]';
ispeak = [scenes_cell{:,4}]';
isfinish = [scenes_cell{:,5}]';
isdeath = [scenes_cell{:,6}]';
isfirst = [scenes_cell{:,10}]';
labels = [scenes_cell{:,1}]';


for i = 1:length(scenes)
    indices = find([scenes_cell{:,1}]' == scenes(i).name);
    times = [scenes_cell{:,9}]';
    plot([times(indices(1))/60000,times(indices(end))/60000], [1,1],'LineWidth',5,'Color',colors(i,:));
    for j = 1:length(indices)
        if isfirst(indices(j))
            if hastimes
                tt = text(times(indices(j))/60000, 1.6, labels(indices(j)),'Color',colors(i,:),'FontSize',17,'FontName','Times New Roman');
            elseif haspal
                tt = text(times(indices(j))/60000, 1.6, labels(indices(j)),'Color',colors(i,:),'FontSize',17,'FontName','Palatino');
            else
                tt = text(times(indices(j))/60000, 1.6, labels(indices(j)),'Color',colors(i,:),'FontSize',17);
            end
            tt(1).FontWeight = 'bold';
            %text(times(indices(j))/60000, 2, labels(indices(j)),'Color',colors(i,:),'FontSize',10);
        end
        if isstart(indices(j))
            scatter((times(indices(j))-2500)/60000,1,5,'Marker','>','MarkerEdgeColor',colors(i,:),'LineWidth',2);
            %scatter(times(indices(j))/60000,1,10,'Marker','.','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 0 0], 'LineWidth', 1);
        elseif ispeak(indices(j))
            scatter(times(indices(j))/60000,1,20,'Marker','.','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 0 0], 'LineWidth', 3);
        elseif isfinish(indices(j))
            scatter((times(indices(j))+2500)/60000,1,5,'Marker','<','MarkerEdgeColor',colors(i,:),'LineWidth',2);
            %scatter(times(indices(j))/60000,1,10,'Marker','.','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 0 0], 'LineWidth', 1);
            %scatter(times(indices(j))/60000,1,40,'Marker','<','MarkerEdgeColor',colors(i,:),'MarkerFaceColor',colors(i,:));
        elseif isdeath(indices(j))
            scatter(times(indices(j))/60000,1,10,'Marker','x','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 0 0],'LineWidth',3);
        end
    end
end


xlim([0 LONGEST_TRIAL_LENGTH_MIN]);
% x ticks every 15 seconds
xticks(0 : 0.25 : ceil(processed_data.fsr.timestamp_ms(end)));
starttick = 0.25;
xticklabels(vertcat(strings(1,starttick/0.25), datestr(datetime((starttick/24/60:1/24/60/60*15:1/24/60*ceil(processed_data.feeltrace.timestamp_ms(end)/60000)),'ConvertFrom','datenum'),'MM:SS')));
xtickangle(90); 
ax = gca;
ax.XGrid = 'on';
 set(ax,'FontSize',30);
 set(ax,'linewidth',1);
xstring = join(repmat(strcat("                                                            P", trial_number),1,32));
xlabel(xstring,'FontSize', 11);
hold off;
yticks([]);
ylabel('Scenes','FontSize',15);

%% PRINT AND SAVE
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 110 16];
print(fullfile(processed_directory,['feeltrace-and-words' char(trial_number)]),'-dpng','-r0');

clearvars isfirst isfinish isdeath colors i indices ispeak isstart j max_fsr ax text_c text_g text_s times wrapped_text x_textpos y_textpos interview_nums interview_nums_num interview_ones LONGEST_TRIAL_LENGTH_MIN max_feeltrace max_keypress MS_PER_MIN ratio starttick xstring;
