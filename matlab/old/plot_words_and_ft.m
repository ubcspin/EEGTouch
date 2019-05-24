% Plot calibrated words and feeltrace.
%% This code is a draft.

load_globals;

clf
hold on
%plot fsrs
max_fsr = max([processed_data.fsr.A0  processed_data.fsr.A1  processed_data.fsr.A2 processed_data.fsr.A3 processed_data.fsr.A4],[],2);
area(processed_data.fsr.timestamp_ms/60000, max_fsr/1023*20, 'FaceColor',[0.9 0.9 0.9],'EdgeColor',[0.9 0.9 0.9]);

max_joystick = max(processed_data.feeltrace.joystick);
plot(processed_data.feeltrace.timestamp_ms/60000, (processed_data.feeltrace.joystick)/max_joystick*20, 'Color',[85/255 165/255 250/255],'LineWidth',2)
plot(processed_data.calibrated_words.timestamp_ms/60000, processed_data.calibrated_words.calibrated_values+10, 'Color', [255/255 179/255 48/255], 'LineWidth', 2)
scatter(processed_data.calibrated_words.timestamp_ms/60000, processed_data.calibrated_words.calibrated_values+10)
x_textpos = processed_data.calibrated_words.timestamp_ms/60000;
y_textpos = processed_data.calibrated_words.calibrated_values+10;
%x_offset = 0.5;
%y_offset = 1;
%for i = 1:length(x_textpos)
    %x_textpos(i) = x_textpos(i) + x_offset - rem(i,2)*x_offset*2;
    %y_textpos(i) = y_textpos(i) + y_offset - rem(i,2)*y_offset*2;
%end

t = text(x_textpos, y_textpos, cellstr(processed_data.calibrated_words.emotion_words));

for i = 1:length(processed_data.calibrated_words.timestamp_ms)
    t(i).Rotation = 80;
    t(i).FontWeight = 'bold';
    t(i).FontSize = 14;
    %t(i).BackgroundColor = [1 1 1];
end

ylim([0,20]);
yticks([0,10,20]);
yticklabels(["Relieved" "-" "Stressed"]);
xticks(0 : 0.25 : ceil(processed_data.fsr.timestamp_ms(end)));
starttick = 0.25;
xticklabels(vertcat(strings(1,starttick/0.25), datestr(datetime((starttick/24/60:1/24/60/60*15:1/24/60*ceil(processed_data.feeltrace.timestamp_ms(end)/60000)),'ConvertFrom','datenum'),'MM:SS')));
xtickangle(90); 
ax = gca;
ax.XGrid = 'on';
hold off;
zoom xon;
%zoom(2);
pan xon;


yyaxis right
ax = get(gcf,'CurrentAxes');
ax.YAxis(2).Color = 'black';
ylabel('Keypress intensity');
yticks([0 20]);
ylim([0,20]);
yticklabels(["Min" "Max"]);

clearvars i starttick t x_offset x_textpos y_offset y_textpos ax