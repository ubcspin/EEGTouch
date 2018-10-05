% cuts a video using a specified length and timestamp
% and superimposes a frame number on each frame
% useful for determining the sync frame of the gameplay recording video

% watch the video in vlc and eyeball a start second and number of seconds
% to process surrounding the sync button changing color. then set the
% values in this script to cut out that part of the video and apply frame
% numbers to every frame.

% video will be exported as:
%[video filename, no extension]-procvid-start-[start time]-len-[length].avi


% Automatically cues up processed video in VLC to review and extract
% timestamp if run on a 64-bit Windows PC with VLC installled.
% If VLC is not installed or a non-Windows computer is not run, does not
% cue up video. I am working remotely and do not have a non-Windows
% computer available for testing. If you do not have VLC download it.

video_file = dir(fullfile(trial_directory,'gameplay*.mov'));
if ~isempty(video_file)
    video_name = video_file.name;
    video_path = video_file.folder;
else
    waitfor(warndlg('Unable to automatically locate gameplay video for this trial. Please find it manually. The file is usually called gameplay-[number].mov and in the main trial directory.'));
    [video_name, video_path] = uigetfile('*.mov','Find gameplay mov');
    isdlg = 'No';
    while (video_name(1) == 0) && strcmp(questdlg('No gameplay video file was opened. Do you want to keep looking for this file yourself?',''),'Yes')
       [video_name, video_path] = uigetfile('*.mov','Find gameplay mov');
    end
    if video_name(1) == 0
        waitfor(errordlg('Aborting data processing: no valid gameplay video file'));
        throw(MException('Custom:Custom','Failure: unable to find valid gameplay video file'));
    end
end

if ~contains(video_name,pathsep)
    video_name = fullfile(video_path,video_name);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SET DURATION TO PROCESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initialize video reader
waitfor(helpdlg('Attempting to play video with VLC. Please watch the video carefully to determine if the sync button was pressed multiple times, and if so, determine which of th multiple button presses corresponds with the correct DIN in the EEG data. Please eyeball a start time in seconds and duration in seconds that would include the sync frame (when the sync button changes color, for the sync instance you want).'));

%Attempting to play video.

 if convertCharsToStrings(computer) == "PCWIN64"
    try
        status = system(['start vlc ' video_name]);
    catch ME
        waitfor(errordlg(['Error trying to open video on VLC. Please open ' video_name '.mov, inside the raw data directory, manually to view video then return to Matlab.']));
    end
elseif convertCharsToStrings(computer) == "MACI64"
    try
        status = system(['open -a vlc ' video_name '.avi']);
    catch ME
        waitfor(errordlg(['Error trying to open video on VLC. Please open ' video_name '.avi manually to view video then return to Matlab.']));
    end
else
     disp(['Video not automatically opened on this system type. Please open ' video_name '.avi manually to view video then return to Matlab.']);
end

vid_reader = VideoReader(video_name);
scalars.frame_rate = vid_reader.FrameRate;
seconds_to_process = [];
start_time_sec = [];
while isempty(seconds_to_process) || isempty(start_time_sec) || seconds_to_process < 0 || seconds_to_process > 60 || start_time_sec < 0 || start_time_sec > seconds_to_process + vid_reader.Duration
    prompt = {'Enter time in seconds to start video processing:','Enter duration in seconds to process:', 'If multiple sync signals sent, enter the correct one to use (first = 1, second = 2, etc)'};
    title = 'Video parameters';
    dims = [1 35];
    definput = {'0','30', '1'};
    answer = inputdlg(prompt,title,dims,definput);
    if ~isempty(answer)
        start_time_sec = str2num(answer{1});
        seconds_to_process = str2num(answer{2});
        scalars.which_gameplay_sync = str2num(answer{3});
        
    end
    if (isempty(answer) || isempty(seconds_to_process) || isempty(start_time_sec) || seconds_to_process < 0 || seconds_to_process > 60 || start_time_sec < 0 || start_time_sec > seconds_to_process + vid_reader.Duration) && ~strcmp(questdlg(['Invalid parameters for video excerpt. Please select a duration of <60 and a start second between 0 and ' num2str(vid_reader.Duration) '. Do you want to try entering different parameters'],''),'Yes')
        waitfor(errordlg('No valid parameters available for video processing. Data processing aborted: cannot process video to extract timestamp.'));
        throw(MException('Custom:Custom' ,'Failure: unable to excerpt video.'));
    end
end

quality_to_export = 50; % out of 100

frame_rate = 30; %% could move this to scalars


f = waitbar(0.4,'Processing video','Name','Data Processing');

% initialize video reader
vid_reader = VideoReader(video_name);
% set time
vid_reader.CurrentTime = start_time_sec;
% export video the same size as it's read
vid_height = vid_reader.Height;
vid_width = vid_reader.Width;
%offset text to right side of video
text_offset = vid_width - 300;

% the following is adapted from matlab example code.
% create struct for storing excerpted video
temp_movie = struct('cdata',zeros(vid_height,vid_width,3,'uint8'),...
    'colormap',[]);

% loop through read video for specified number of seconds, using frame rate.
% do not attempt to seek beyond the end of the video
k = 1;
while k < seconds_to_process * frame_rate && hasFrame(vid_reader)
    temp_movie(k).cdata = insertText(readFrame(vid_reader),[text_offset 1], ['frame ' num2str(k+start_time_sec*frame_rate)], 'FontSize', 50, 'BoxColor', 'black', 'TextColor', 'white');
    k = k+1;
end

% initialize write object to save excerpt
if contains(video_name,pathsep)
    video_name = video_name(strfind(video_name,pathsep):end);
end
proc_vid_name = strcat('gameplay-',trial_number,'-procvid-start-',num2str(start_time_sec),'-len-',num2str(seconds_to_process));
proc_vid_name = char(fullfile(processed_directory, proc_vid_name));
% set quality
vid_out = VideoWriter(proc_vid_name);
vid_out.Quality = quality_to_export;
% open file
open(vid_out);
% write video
writeVideo(vid_out, temp_movie);
% close file
close(vid_out);

clearvars seconds_to_process start_time quality_to_export vid_height vid_width text_offset temp_movie k vid_out;
close(f);
waitfor(helpdlg('Attempting to play the video we just processed. Please find the frame number for the FIRST FRAME WHEN THE SYNC BUTTON CHANGES COLOR (for the sync instance you want) then close the video player and return to Matlab.'));

%This is only executed if you have a 64-bit Windows PC and VLC is on your
%path.
if convertCharsToStrings(computer) == "PCWIN64"
    try
        status = system(['start vlc ' proc_vid_name '.avi']);
    catch ME
        waitfor(errordlg(['Error trying to open video on VLC. Please open ' proc_vid_name '.avi manually to view video then return to Matlab.']));
    end
elseif convertCharsToStrings(computer) == "MACI64"
    try
        status = system(['open -a vlc ' fullfile(pwd,proc_vid_name) '.avi']);
    catch ME
        waitfor(errordlg(['Error trying to open video on VLC. Please open ' proc_vid_name '.avi manually to view video then return to Matlab.']));
    end
else
     disp(['Video not automatically opened on this system type. Please open ' proc_vid_name '.avi manually to view video then return to Matlab.']);
end

%%%%
sync_frame = -1;
while sync_frame < 0 || sync_frame > vid_reader.Duration*30
    prompt = {'Enter number for frame number for the FIRST FRAME WHEN THE SYNC BUTTON CHANGES COLOR (for the sync instance you want).'};
    title = 'Enter sync frame';
    dims = [1 35];
    definput =cellstr('0');
    answer = inputdlg(prompt,title,dims,definput);
    if ~isempty(answer)
        sync_frame = str2num(answer{1});
    end
    if (sync_frame < 0 || sync_frame > vid_reader.Duration*30 || floor(sync_frame) ~= sync_frame) && ~strcmp(questdlg(['Invalid sync frame number. Please double-check the frame stamps in VLC and write the response as a positive integer between 0 and ' num2str(vid_reader.Duration*30) '. Do you want to try again?'],''),'Yes')
        waitfor(errordlg('No valid sync frame available. Data processing aborted: no sync frame available.'));
        throw(MException('Custom:Custom','Failure: no sync frame.'));
    end
end

scalars.sync_frame = sync_frame;
waitfor(helpdlg('Sync frame saved.'));
%clearvars vid_reader status isdlg frame_rate video_path start_time_sec sync_frame prompt title dims definput answer vid_name proc_vid_name prompt title dims definput answer video_file video_name isdlg frame_rate oldpath;