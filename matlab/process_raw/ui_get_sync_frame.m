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

function [sync_frame, frame_rate, which_sync] = ui_get_sync_frame(local_paths, num_syncs)

% Frame-number-finding video is at 50% quality..
quality_to_export = 50; % out of 100

% Get video - find in directory or from UI dialog.

video_file_pattern = '*gameplay*.mov';
video_file_title = 'gameplay video';
video_file_descrip = 'The file is usually called gameplay-[number].mov and in the main trial directory.';
video_name = get_path_ui(local_paths.trial_directory, video_file_pattern, video_file_title, video_file_descrip,true,false);

% initialize video reader
% Attempting to play video.
% This auto-opens the video in VLC on Windows. Auto-open script attempted on
% Mac but it doesn't work.
autoplay_video(video_name);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SET DURATION TO PROCESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%a
% initialize video reader
vid_reader = VideoReader(video_name);
frame_rate = vid_reader.FrameRate;
% Prompt for how many seconds of the video to process (to assign frame number to).
[start_time_sec, secs_to_process, which_sync] = get_start_time_and_secs(vid_reader.Duration, num_syncs);

% advance to start of clip framewise
absolute_frame_index = 1;
while (absolute_frame_index < start_time_sec * frame_rate) && hasFrame(vid_reader)
    readFrame(vid_reader);
    absolute_frame_index = absolute_frame_index + 1;
end

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
relative_frame_index = 1;
while (absolute_frame_index < (start_time_sec + secs_to_process) * frame_rate) && hasFrame(vid_reader)
    temp_movie(relative_frame_index).cdata = insertText(readFrame(vid_reader),[text_offset 1], ['frame ' num2str(absolute_frame_index)], 'FontSize', 50, 'BoxColor', 'black', 'TextColor', 'white');
    absolute_frame_index = absolute_frame_index+1;
    relative_frame_index = relative_frame_index+1;
end

% initialize write object to save excerpt
if contains(video_name,pathsep)
    video_name = video_name(strfind(video_name,pathsep):end);
end

proc_vid_name = strcat('procvid-start-',num2str(start_time_sec),'-len-',num2str(secs_to_process));
proc_vid_name = char(fullfile(local_paths.processed_directory, proc_vid_name));
% set quality
vid_out = VideoWriter(proc_vid_name);
vid_out.Quality = quality_to_export;
% open file
open(vid_out);
% write video
writeVideo(vid_out, temp_movie);
% close file
close(vid_out);

waitfor(helpdlg('Attempting to play the video we just processed. Please find the frame number for the FIRST FRAME WHEN THE SYNC BUTTON CHANGES COLOR (for the sync instance you want) then close the video player and return to Matlab.'));
autoplay_video([proc_vid_name '.avi']);

%%%%
sync_frame = get_sync_frame(vid_reader.Duration*frame_rate);
end

function [start_time_sec, secs_to_process, which_sync] = get_start_time_and_secs(vid_duration_sec, num_syncs)
    start_time_sec = [];
    secs_to_process = [];
    
    if num_syncs > 1
        %determine which sync to use
%         msg = [{['More than one ' file_or_folder ' matches the pattern ' the_pattern '. Please select the appropriate ' the_descript ' to use.']} {''} {help_message} {''} {''} {''} {''}];
%         title = ['Select ' file_or_folder];
%         list = {};
        msg = [{'The sync button was pressed more than once.'} {''} {'Which sync button press corresponds with the DIN signal being used?'} {''} {'Please find the frame number for that sync button press.'} {''} {''} {''} {''}];
        title = 'Select sync';
        list = cellfun(@num2str, num2cell(1:num_syncs),'un',0);
        tf = false;
        while ~tf
            [which_sync,tf] = listdlg('PromptString',msg,'Name',title,'ListSize',[200,100],'SelectionMode','single','ListString',list);
            if ~tf
                if strcmp(questdlg('No sync selected. Do you want to try again?','No sync selected','Yes','No','Yes'),'No')
                    waitfor(errordlg('Error: refusal to choose a sync when more than one exists', 'Did Not Choose Sync'));
                    throw(MException('Custom:Custom' ,'Failure: refusal to choose sync.'));
                end
            end
        end
    else
        which_sync = 1;
    end
    
    while isempty(start_time_sec)|| isempty(secs_to_process) || secs_to_process < 0 || secs_to_process > 60 || start_time_sec < 0 || start_time_sec > secs_to_process + vid_duration_sec
        prompt = {'Enter time in seconds to start video processing:','Enter duration in seconds to process:'};
        title = 'Video parameters';
        dims = [1 35];
        definput = {'0','30'};
        answer = inputdlg(prompt,title,dims,definput);
        if ~isempty(answer)
            start_time_sec = str2num(answer{1});
            secs_to_process = str2num(answer{2});
            %processed_data.scalars.which_gameplay_sync = str2num(answer{3});
        end
        if (isempty(answer) || isempty(secs_to_process) || isempty(start_time_sec) || secs_to_process < 0 || secs_to_process > 60 || start_time_sec < 0 || start_time_sec > secs_to_process + vid_duration_sec) && ~strcmp(questdlg(['Invalid parameters for video excerpt. Please select a duration of <60 and a start second between 0 and ' num2str(vid_duration_sec) '. Do you want to try entering different parameters?'],'Invalid Video Parameters','Yes','No','Yes'),'Yes')
            waitfor(errordlg('Cannot make timestamped video excerpt: no valid parameters available.','Cannot Make Timestamped Video Excerpt'));
            throw(MException('Custom:Custom' ,'Failure: Did not choose valid parameters for timestamped video.'));
        end
    end
end

function is_autoplay_successful = autoplay_video(video_name)
    error_text = ['Error trying to open video on VLC. Please open ' video_name ' manually to view video then return to Matlab.'];
    if convertCharsToStrings(computer) == "PCWIN64"
        try
            system(['start vlc ' video_name]);
        catch ME
            waitfor(errordlg(error_text));
            is_autoplay_successful = false;
            return;
        end
    % Mac case doesn't work and needs to open manually. :(.
    elseif convertCharsToStrings(computer) == "MACI64"
        try
            system(['open -a vlc ' video_name]);
        catch ME
            waitfor(errordlg(error_text));
            is_autoplay_successful = false;
            return;
        end
    else
         % Other OS: prompt to open video manually.
        waitfor(errordlg(error_text));
        is_autoplay_successful = false;
        return;
    end
    is_autoplay_successful = true;
end

function sync_frame = get_sync_frame(last_frame)
    sync_frame = -1;
    while sync_frame < 0 || sync_frame > last_frame
        prompt = {'Enter number for frame number for the FIRST FRAME WHEN THE SYNC BUTTON CHANGES COLOR (for the sync instance you want).'};
        title = 'Enter sync frame';
        dims = [1 35];
        definput =cellstr('0');
        answer = inputdlg(prompt,title,dims,definput);
        if ~isempty(answer)
            sync_frame = str2num(answer{1});
        end
        if (sync_frame < 0 || sync_frame > last_frame || floor(sync_frame) ~= sync_frame) && ~strcmp(questdlg(['Invalid sync frame number. Please double-check the frame stamps in VLC and write the response as a positive integer between 0 and ' num2str(last_frame) '. Do you want to try again?'],''),'Yes')
            waitfor(errordlg('No valid sync frame available. Data processing aborted: no sync frame available.'));
            throw(MException('Custom:Custom' ,'Failure: no trial number.'));
        end
    end
end