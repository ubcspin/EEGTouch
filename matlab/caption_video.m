% nsure variables are loaded.
load_globals;

% Get video - find in directory or from UI dialog.
video_name = get_path_ui(trial_directory, 'gameplay*.mov', 'gameplay video', 'The file is usually called gameplay-[number].mov and in the main trial directory.',true);
% Initialize video reader from .mov file.
vid_reader = VideoReader(video_name);

quality_to_export = 40;
factor_to_resize = 0.4;
caption_room = 75;

%crop one frame to get the size
im2res = readFrame(vid_reader);
im = imresize(im2res,factor_to_resize);
[vid_height, vid_width, ~] = size(im);
vid_height = vid_height + caption_room;
%[im2crop, rect] = imcrop(im2crop);
% vid_width = fix(rect(3));
% vid_height = fix(rect(4)) + 30;
vid_reader = VideoReader(video_name);

%captioned (temp) and uncaptioned movie structs
temp_movie = struct('cdata',zeros(vid_height,vid_width,3,'uint8'),...
    'colormap',[]);
% final_movie = struct('cdata',zeros(250,250,3,'uint8'),...
%     'timestamp_ms',[]);

%discards all frames before sync_frame
i = 1;
start_frame = min(min(min(processed_data.events.game.timestamp_ms(1),processed_data.events.sound.timestamp_ms(1)), processed_data.events.character.timestamp_ms(1)), processed_data.interview.timestamp_ms(1))*30/1000 - 1;

while i < processed_data.scalars.sync_frame + start_frame
    readFrame(vid_reader);
    i = i+1;
end

%now reads entire video
j = 1;
gk = 1;
sk = 1;
ck = 1;
ik = 1;
l = i - processed_data.scalars.sync_frame;
NUM_OF_FRAMES_TO_PROC = 1000;
no_label_chars = '-';
really_big_num = 9999999999999999;
expiry_frames = 30;
i_expiry_frames = 150;
gtext = no_label_chars;
stext = no_label_chars;
ctext = no_label_chars;
itext = no_label_chars;
gtext_expiry_frame = really_big_num;
stext_expiry_frame = really_big_num;
ctext_expiry_frame = really_big_num;
itext_expiry_frame = really_big_num;
while hasFrame(vid_reader) && j < NUM_OF_FRAMES_TO_PROC
    res_frame = imresize(readFrame(vid_reader), factor_to_resize);
    
    if round(l*1000/30) >= processed_data.events.game.timestamp_ms(gk) 
        gtext = processed_data.events.game.label(gk);
        gk = gk + 1;
        gtext_expiry_frame = l + expiry_frames;
    elseif l == gtext_expiry_frame
        gtext = no_label_chars;
    end
    
    if round(l*1000/30) >= processed_data.events.sound.timestamp_ms(sk) 
        stext = processed_data.events.sound.label(sk);
        sk = sk + 1;
        stext_expiry_frame = l + expiry_frames;
    elseif l == stext_expiry_frame
        stext = no_label_chars;
    end
    
    if round(l*1000/30) >= processed_data.events.character.timestamp_ms(ck) 
        ctext = processed_data.events.character.label(ck);
        ck = ck + 1;
        ctext_expiry_frame = l + i_expiry_frames;
    elseif l == itext_expiry_frame
        itext = no_label_chars;
    end
    
    if round(l*1000/30) >= processed_data.interview.timestamp_ms(ik) 
        itext = processed_data.interview.label(ik);
        ik = ik + 1;
        itext_expiry_frame = i + expiry_frames;
    elseif l == itext_expiry_frame
        itext = no_label_chars;
    end
    
    this_frame = insertText(cat(1,res_frame,zeros(caption_room,vid_width,3,'uint8')), [1 vid_height-70], {['game: ' char(gtext)]}, 'FontSize', 10, 'BoxColor', 'black', 'TextColor', 'white');
    this_frame = insertText(this_frame, [1 vid_height-55], {['sound: ' char(stext)]}, 'FontSize', 10, 'BoxColor', 'black', 'TextColor', 'white');
    this_frame = insertText(this_frame, [1 vid_height-40], {['character: ' char(ctext)]}, 'FontSize', 10, 'BoxColor', 'black', 'TextColor', 'white');
    this_frame = insertText(this_frame, [1 vid_height-25], {['interview: ' char(itext)]}, 'FontSize', 10, 'BoxColor', 'black', 'TextColor', 'white');
    temp_movie(j).cdata = this_frame;
    %final_movie(k).cdata = temp_movie(k).cdata; %cat(2, cat(1, cropped_frame, zeros(250-(ceil(rect(4))), ceil(rect(3)),3,'uint8')),zeros(250, 250-ceil(rect(3)), 3, 'uint8'));
    %final_movie(k).timestamp_ms = round((k-1)*1000/processed_data.scalars.frame_rate);
    l = l+1;
    j = j+1;
end

%saves captioned version to file
vid_out = VideoWriter(fullfile(processed_directory, ['testvid_' trial_number])); %[video_name(1:end-4) '-testvid-' num2str(vid_height) 'x' num2str(vid_width)]);
vid_out.Quality = quality_to_export;
open(vid_out);
writeVideo(vid_out, temp_movie);
close(vid_out);

%face_vid_data = final_movie;

clearvars cropped_frame final_movie im2crop k quality_to_export rect temp_movie vid_height vid_out vid_reader vid_width video_name