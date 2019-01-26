function nodiff_version = remove_time_nodiffs(value_matrix, times)


%time_diffs = diff(gameplay_fromsync(:,6));
time_diffs = diff(times);
time_diffs(isnan(time_diffs))=0;
time_nodiffs = ~time_diffs;
%k = start of run where time is static
k = 1;
% l = end of run where time is static
l = 1;
% m = index in nodiffs vector
m = 1;
nodiffs_vec = zeros(length(time_nodiffs),2);
while ~isempty(k)
    k = k+find(time_nodiffs(k:end),1)-1;
    l = find(time_diffs(k:end),1)-1;
    if ~isempty(k) && ~isempty(l)
        nodiffs_vec(m,:) = [k k+l];
    end
    k = k+l;
    m = m+1;
end

%crop nodiffs vector of trailing 0s
%zind = index of first trailing 0
zind = find(nodiffs_vec(:,1) == 0,1);
if ~isempty(zind)
    nodiffs_vec = nodiffs_vec(1:zind-1,:);
end


%remove duplicate timestamps
%b = running offset as all sensor data collected during a timestamp is
%averaged into a single datapoint
b = 0;
for k = 1:length(nodiffs_vec)
    averagel = mean(value_matrix(nodiffs_vec(k,1)-b:nodiffs_vec(k,2)-b,:),1);
    value_matrix = vertcat(value_matrix(1:nodiffs_vec(k,1)-1-b,:), averagel, value_matrix(nodiffs_vec(k,2)+1-b:end,:));
    b = b + nodiffs_vec(k,2) - nodiffs_vec(k,1);
end
nodiff_version = value_matrix;
end