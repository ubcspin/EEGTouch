
load_globals;
% Get video - find in directory or from UI dialog.
video_name = get_path_ui(trial_directory, '*gameplay-small*.mp4', 'gameplay small video', 'The file is usually called gameplay-small-[number].mov and was in the small gameplay folder on the server',true);
% Initialize video reader from .mov file. 
vid_reader = VideoReader(video_name);


quality_to_export = 40;
%factor_to_resize = 1;
clf;
%crop one frame to get the size
im2res = readFrame(vid_reader);
%im = imresize(im2res,factor_to_resize);
im = im2res;
[vid_height, vid_width, ~] = size(im);
% [im2crop, rect] = imcrop(im2res);
% crop_width = fix(rect(3));
% crop_height = fix(rect(4)) + 30;
rect = [159 123 560 356];
rect_width = rect(3);
rect_height = rect(4);
%rect_width = round(factor_to_resize*fix(rect(3)));
%rect_height = round(factor_to_resize*fix(rect(4)));
vid_reader = VideoReader(video_name);

%captioned (temp) and uncaptioned movie structs
temp_movie = struct('cdata',zeros(rect_width,rect_height,3,'uint8'),...
    'colormap',[]);
% final_movie = struct('cdata',zeros(250,250,3,'uint8'),...
%     'timestamp_ms',[]);

%discards all frames before sync_frame
i = 1;
%start_frame = min(min(min(processed_data.events.game.timestamp_ms(1),processed_data.events.sound.timestamp_ms(1)), processed_data.events.character.timestamp_ms(1)), processed_data.interview.timestamp_ms(1))*30/1000 - 1;

while i < processed_data.scalars.sync_frame
    fr = readFrame(vid_reader);
    i = i+1;
end

j = 1;
k = 1;

timez = [];

while hasFrame(vid_reader)
    res_frame = readFrame(vid_reader);
    i = i+1;
    j = j+1;
    if rem(j,450) == 0
        crop_frame = imcrop(res_frame, rect);
        this_frame = crop_frame; %imresize(crop_frame, factor_to_resize);
        temp_movie(k).cdata = this_frame;
        timez(k) = j*1000/30;
        k = k+1;
    end
end



frames_table = table(timez', temp_movie', 'VariableNames', {'timestamp_ms', 'frames'});
processed_data.frames = frames_table;

%processed_data.frames.timestamp_ms = timez;
%processed_data.frames.frames = temp_movie;
clearvars crop_frame fr frames_table rect rect_height rect_width temp_movie timez factor_to_resize i im im2res j k quality_to_export res_frame this_frame vid_height vid_reader vid_width video_name
