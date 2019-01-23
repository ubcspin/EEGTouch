function nodiff_version = remove_time_nodiffs(value_matrix, times)

% array where timestamp is in different millisecond
%time_ischanged = ischange(times,'Threshold',0.0000000001);
isdiff = diff(times) ~= 0;

% array of indices where timestamp is in different millisecond
%changept_indices = vertcat(1, find(time_ischanged),length(times)+1);
changept_indices = vertcat(1, find(isdiff)+1, length(times)+1);

% prepare array for compiled values of unique timestamps
con_values = zeros(length(changept_indices)-1,1);
%and array of unique video timestamps
con_times = zeros(length(changept_indices)-1,1);

%populate arrays
for k = 1:length(changept_indices)-1
    con_values(k) = median(value_matrix(changept_indices(k):changept_indices(k+1)-1));
    con_times(k) = times(changept_indices(k));
end

nodiff_version = zeros(length(changept_indices)-1,2);

nodiff_version(:,1) = con_values;
nodiff_version(:,2) = con_times;
