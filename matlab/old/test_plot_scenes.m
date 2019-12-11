LONGEST_TRIAL_LENGTH_MIN = 20;

%subplot(29,1,[28 29]);
hold on;
grid on;

%colors = [[0, 0.4470, 0.7410];[0, 0.4470, 0.7410]]

for i = 1:length(scenes)
    indices = find([scenes_cell{:,1}]' == scenes(i).name);
    times = [scenes_cell{:,9}]';
    plot([times(indices(1))/60000,times(indices(end))/60000], [1,1],'LineWidth',5);
    for j = 1:length(indices)
        %do something
    end
end


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