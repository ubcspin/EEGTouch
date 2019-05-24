clf
xes = 1:66;
hist_xes = 0:9;
xlabs = strings(10,1);


colors = repmat([0 0 0],20,1);
colors(8,:) = [1 0 0];
colors(10,:) = [0 1 0];
colors(15,:) = [0 0 1];

hold on;

for i = 1:20
    %hist_i = histcounts(imps(i,:),10);
    %scatter(xes, hist_i, 'MarkerEdgeColor',colors(i,:));
    plot(hist_xes, histcounts(imps(i,:),10), 'Color',colors(i,:));

end

plot(hist_xes, histcounts(imps(8,:),10), 'Color', [1 0 0],'LineWidth', 2);
plot(hist_xes, histcounts(imps(10,:),10), 'Color', [0 1 0],'LineWidth', 2);
plot(hist_xes, histcounts(imps(15,:),10), 'Color', [0 0 1],'LineWidth', 2);

 xes_labels = 0:10:100;
 for i = 1:10
     xlabs(i) = string([num2str(xes_labels(i)) '-' num2str(xes_labels(i+1))]);
 end
ax = gca;
xlim([-0.5,9.5]);
xticks(-0.5:1:10.5);
xticklabels(xes_labels);

text(8.5,22,'P14','Color',[1 0 0]);
text(8.5,20,'P16','Color',[0 1 0]);
text(8.5,18,'P21','Color',[0 0 1]);

    