% nsure variables are loaded.
load_globals;

% Get video - find in directory or from UI dialog.
video_name = get_path_ui(trial_directory, 'gameplay*.mov', 'gameplay video', 'The file is usually called gameplay-[number].mov and in the main trial directory.',true);
% Initialize video reader from .mov file.
vid_reader = VideoReader(video_name);

quality_to_export = 100;

%crop one frame to get the size
im2crop = readFrame(vid_reader);
[im2crop, rect] = imcrop(im2crop);
vid_width = fix(rect(3));
vid_height = fix(rect(4)) + 30;
vid_reader = VideoReader(video_name);

%captioned (temp) and uncaptioned movie structs
temp_movie = struct('cdata',zeros(vid_height,vid_width,3,'uint8'),...
    'colormap',[]);
final_movie = struct('cdata',zeros(250,250,3,'uint8'),...
    'timestamp_ms',[]);

%discards all frames before sync_frame
for k= 1:processed_data.scalars.sync_frame-1
    readFrame(vid_reader);
end

%now reads entire video
k = 1;
while hasFrame(vid_reader)
    cropped_frame = imcrop(readFrame(vid_reader), rect);
    temp_movie(k).cdata = insertText(cat(1,cropped_frame,zeros(20,ceil(rect(3)),3,'uint8')), [1 vid_height-25], ['frame ' num2str(k)], 'FontSize', 10, 'BoxColor', 'black', 'TextColor', 'white');
    final_movie(k).cdata = cat(2, cat(1, cropped_frame, zeros(250-(ceil(rect(4))), ceil(rect(3)),3,'uint8')),zeros(250, 250-ceil(rect(3)), 3, 'uint8'));
    final_movie(k).timestamp_ms = round((k-1)*1000/processed_data.scalars.frame_rate);
    k = k+1;
end

%saves captioned version to file
vid_out = VideoWriter([video_name(1:end-4) '-cropvid-' num2str(vid_height) 'x' num2str(vid_width)]);
vid_out.Quality = quality_to_export;
status = open(vid_out);
writeVideo(vid_out, temp_movie);
close(vid_out);

face_vid_data = final_movie;

clearvars cropped_frame final_movie im2crop k quality_to_export rect temp_movie vid_height vid_out vid_reader vid_width video_name