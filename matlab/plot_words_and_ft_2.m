% Plots FSRs, feeltrace on interview into big printable image.

%TODO: make this a function
%TODO: refactor helpers

% Load directories and data.
load_globals;
clf;

MS_PER_MIN = 60000;
LONGEST_TRIAL_LENGTH_MIN = 20;

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
subplot(29,1,[1 2 3 4 5 6 7 8 9 10 11 12]);
hold on;
grid on;
% line plot the feeltrace
plot(processed_data.feeltrace.timestamp_ms/60000,(processed_data.feeltrace.joystick-112)/11.2,'Color',[85/255 165/255 250/255],'LineWidth',2);
% line plot the calibrated words
plot(processed_data.calibrated_words.timestamp_ms/60000, processed_data.calibrated_words.calibrated_values, 'Color', [255/255 179/255 48/255], 'LineWidth', 2)
% scatter plot the calibrated words
scatter(processed_data.calibrated_words.timestamp_ms/60000, processed_data.calibrated_words.calibrated_values)
% set positions for calibrated words text
x_textpos = processed_data.calibrated_words.timestamp_ms/60000;
y_textpos = processed_data.calibrated_words.calibrated_values;
% plot calibrated words text
text_g = text(x_textpos, y_textpos, cellstr(processed_data.calibrated_words.emotion_words));

% set text angle, weight, size
for i = 1:length(processed_data.calibrated_words.timestamp_ms)
    text_g(i).Rotation = 80;
    text_g(i).FontWeight = 'bold';
    text_g(i).FontSize = 20;
end

% set range from -10 to 10
ylim([-10,10]);
% y ticks at maximum, minimum, middle
yticks([-10,0,10]);
% label direction of y axis
yticklabels(["Relieved" "-" "Stressed"]);
% set domain to longest trial length for equivalent figure size
xlim([0 LONGEST_TRIAL_LENGTH_MIN]);
% x ticks every 15 seconds
xticks(0 : 0.25 : ceil(processed_data.fsr.timestamp_ms(end)));
xticklabels([]);
xtickangle(90); 
ax = gca;
ax.XGrid = 'on';
 set(ax,'FontSize',30);
 set(ax,'linewidth',1);
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
    y_textpos(i) = processed_data.feeltrace.joystick(j-1)/225;
end

wrapped_text = arrayfun(@(c) textwrap(c,20), processed_data.interview.label,'UniformOutput',false);
text_g = text(x_textpos, y_textpos, wrapped_text);

for i = 1:length(processed_data.interview.timestamp_ms)
    text_g(i).Rotation = 90;
    text_g(i).FontWeight = 'bold';
    text_g(i).FontSize = 10;
end

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

% game events
x_textpos = processed_data.events.game.timestamp_ms/60000;
y_textpos = zeros(length(processed_data.events.game.timestamp_ms),1);
wrapped_text = arrayfun(@(c) textwrap(c,30), processed_data.events.game.label,'UniformOutput',false);
text_g = text(x_textpos, y_textpos, wrapped_text);

for i = 1:length(processed_data.events.game.timestamp_ms)
    text_g(i).Rotation = 90;
    text_g(i).FontWeight = 'bold';
    text_g(i).FontSize = 10;
end

% sound events
x_textpos = processed_data.events.sound.timestamp_ms/60000;
y_textpos = zeros(length(processed_data.events.sound.timestamp_ms),1);
wrapped_text = arrayfun(@(c) textwrap(c,30), processed_data.events.sound.label,'UniformOutput',false);
text_s = text(x_textpos, y_textpos, wrapped_text);

for i = 1:length(processed_data.events.sound.timestamp_ms)
    text_s(i).Rotation = 90;
    text_s(i).FontWeight = 'bold';
    text_s(i).FontSize = 10;
end

% character events
x_textpos = processed_data.events.character.timestamp_ms/60000;
y_textpos = zeros(length(processed_data.events.character.timestamp_ms),1);
wrapped_text = arrayfun(@(c) textwrap(c,30), processed_data.events.character.label,'UniformOutput',false);
text_c = text(x_textpos, y_textpos, wrapped_text);

for i = 1:length(processed_data.events.character.timestamp_ms)
    text_c(i).Rotation = 90;
    text_c(i).FontWeight = 'bold';
    text_c(i).FontSize = 10;
end

yticks([]);
xlim([0 LONGEST_TRIAL_LENGTH_MIN]);
xticks(0 : 0.25 : ceil(processed_data.fsr.timestamp_ms(end)));
xticklabels([]);

 %% SUBPLOT 4
subplot(29,1,[23 24 25 26 27]);
hold on;
grid on;

for i = 1:length(temp_movie)
    image([(i-1)/4 i/4],[0 1], imrotate(temp_movie(i).cdata,90));
end

yticks([]);
xlim([0 LONGEST_TRIAL_LENGTH_MIN]);
xticks(0 : 0.25 : ceil(processed_data.fsr.timestamp_ms(end)));
starttick = 0.25;
xticklabels(vertcat(strings(1,starttick/0.25), datestr(datetime((starttick/24/60:1/24/60/60*15:1/24/60*ceil(processed_data.feeltrace.timestamp_ms(end)/60000)),'ConvertFrom','datenum'),'MM:SS')));
xtickangle(90); 
ax = gca;
ax.XGrid = 'on';
 set(ax,'FontSize',30);
 set(ax,'linewidth',1);
hold off;

%% PRINT AND SAVE
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 110 16];
print(fullfile(processed_directory,['fsr_and_feeltrace-over' char(trial_number)]),'-dpng','-r0');

clearvars ax interview_nums interview_nums_num interview_ones LONGEST_TRIAL_LENGTH_MIN max_feeltrace max_keypress MS_PER_MIN ratio starttick xstring;