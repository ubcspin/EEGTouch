%extract unique-timestamp feeltrace data, sync feeltrace timestamps
%and compile concise array of feeltrace data and timestamps
%name of feeltrace file
% If no trial directory variable, try current directory.
if ~exist('trial_directory', 'var')
    global trial_directory;
    trial_directory = get_path_ui(pwd, '', 'trial directory', 'This is the directory that contains one trial worth of raw data you downloaded from the server.', false);
end

% Get csv - find in directory or from UI dialog.
feeltrace_file = get_path_ui(trial_directory, 'feeltrace*.csv', 'feeltrace .csv file', 'The file is usually called feeltrace-[number].csv and in the main trial directory.',true);
filename = feeltrace_file;

% Extract feeltrace and video timestamp columns from csv
feeltrace_joystick = get_numerical_csv_column(filename, 6);
feeltrace_videoTimestamp = get_numerical_csv_column(filename, 9);

%copy over raw data, remove header row
feeltrace_joystick = feeltrace_joystick(2:end);
feeltrace_videoTimestamp = feeltrace_videoTimestamp(2:end);


% %find where video actually starts playing, remove data before
% vid_start_index = find(feeltrace_videoTimestamp > 0, 1)+1;
% feeltrace_joystick = feeltrace_joystick(vid_start_index:end);
% feeltrace_videoTimestamp = feeltrace_videoTimestamp(vid_start_index:end);

vid_start_index = find(feeltrace_videoTimestamp >0, 1)+1;
feeltrace_joystick = feeltrace_joystick(vid_start_index:end);
feeltrace_videoTimestamp = feeltrace_videoTimestamp(vid_start_index:end)

%convert to milliseconds, subtract sync offset and round to integer
feeltrace_round_times_ms = round((feeltrace_videoTimestamp*1000 - (processed_data.scalars.sync_frame*1000 / processed_data.scalars.frame_rate)));

%transpose joystick data: subtract minimum
feeltrace_joystick = feeltrace_joystick - min(feeltrace_joystick);

nodiffs = remove_time_nodiffs(horzcat(feeltrace_joystick, feeltrace_round_times_ms), feeltrace_round_times_ms);

% %% DIFF REMOVE
% %array of indices where video timestamp is in differend millisecond
% feeltrace_vidTimeChanged = ischange(feeltrace_round_times_ms);
% 
% %array of indices where video timestamp is in different millisecond
% changept_indices = vertcat(1, find(feeltrace_vidTimeChanged));
% 
% %prepare array of compiled joystick values for unique timestamps
% con_joystick = zeros(length(changept_indices),1);
% %and array of unique video timestamps
% con_vidTimestamp = zeros(length(changept_indices),1);
% 
% %populate arrays
% for k = 1:length(changept_indices)-1
%     con_joystick(k) = median(feeltrace_joystick(changept_indices(k):changept_indices(k+1)-1));
%     con_vidTimestamp(k) = feeltrace_round_times_ms(changept_indices(k));
% end
%%

%collect data into table
%feeltrace_condensed = table(con_vidTimestamp, con_joystick, 'VariableNames', {'timestamp_ms' 'joystick'});
feeltrace_condensed = table(nodiffs(:,2), nodiffs(:,1),'VariableNames', {'timestamp_ms' 'joystick'});
%feeltrace_condensed = feeltrace_condensed(1:find(feeltrace_condensed.timestamp_ms == 0, 1)-1,:);

processed_data.feeltrace = feeltrace_condensed;
%align feeltrace data to master array
% aligned_data(1).feeltrace = [];
% l = 1;
% a = length(feeltrace_condensed.joystick);
% for k=1:length([aligned_data.timestamp_ms])
%     if l > a
%         break;
%     end
%     if feeltrace_condensed.timestamp_ms(l) == aligned_data(k).timestamp_ms
%         aligned_data(k).feeltrace = feeltrace_condensed.joystick(l);
%         l = l+1;
%     else
%         aligned_data(k).feeltrace = [];
%     end  
% end
% close(f);
% save(fullfile(processed_directory, 'processed_data.mat'),'aligned_data', 'processed_data.scalars');
%clear excess variables
%clearvars f feeltrace_condensed feeltrace_file feeltrace_path k a isdlg feeltrace_name feeltrace feeltrace_joystick feeltrace_videoTimestamp vid_start_index feeltrace_round_times_ms feeltrace_vidTimeChanged changept_indices con_joystick con_vidTimestamp l;