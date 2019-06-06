function scenes_played = extract_scenes(trial_data)
    scenes = get_scenes_list();
    
    % aligning scene times
    scenes_log = [];
    scenes_mat = [];
    mat_ind = 1;

    for i = 1:length(scenes)
        for j = 1:length(scenes(i).begin)
            begin_event_stream = getfield(trial_data.events, scenes(i).begin(j).stream);
            begin_event_labels = lower(begin_event_stream.label);
            begin_event_inds = find(begin_event_labels == lower(scenes(i).begin(j).tag));
            begin_event_time = begin_event_stream.timestamp_ms(begin_event_inds);
            for k = 1:length(begin_event_inds)
                scenes_log(i).begin(j).type(k).label = scenes(i).begin(j).tag;
                scenes_log(i).begin(j).type(k).ind = begin_event_inds(k);
                scenes_log(i).begin(j).type(k).time = begin_event_time(k);

                scenes_mat(mat_ind).name = scenes(i).name;
                scenes_mat(mat_ind).stream = scenes(i).begin(j).stream;
                scenes_mat(mat_ind).isbegin = true;
                scenes_mat(mat_ind).ispeak = false;
                scenes_mat(mat_ind).isfinish = false;
                scenes_mat(mat_ind).isdeath = false;
                scenes_mat(mat_ind).label = scenes(i).begin(j).tag;
                scenes_mat(mat_ind).ind = begin_event_inds(k);
                scenes_mat(mat_ind).time = begin_event_time(k);
                mat_ind = mat_ind+1;
            end
        end

        for j = 1:length(scenes(i).peak)
            peak_event_stream = getfield(trial_data.events, scenes(i).peak(j).stream);
            peak_event_labels = lower(peak_event_stream.label);
            peak_event_inds = find(peak_event_labels == lower(scenes(i).peak(j).tag));
            peak_event_time = peak_event_stream.timestamp_ms(peak_event_inds);
            for k = 1:length(peak_event_inds)
                scenes_log(i).peak(j).type(k).label = scenes(i).peak(j).tag;
                scenes_log(i).peak(j).type(k).ind = peak_event_inds(k);
                scenes_log(i).peak(j).type(k).time = peak_event_time(k);

                scenes_mat(mat_ind).name = scenes(i).name;
                scenes_mat(mat_ind).stream = scenes(i).peak(j).stream;
                scenes_mat(mat_ind).isbegin = false;
                scenes_mat(mat_ind).ispeak = true;
                scenes_mat(mat_ind).isfinish = false;
                scenes_mat(mat_ind).isdeath = false;
                scenes_mat(mat_ind).label = scenes(i).peak(j).tag;
                scenes_mat(mat_ind).ind = peak_event_inds(k);
                scenes_mat(mat_ind).time = peak_event_time(k);
                mat_ind = mat_ind+1;
            end
        end

        for j = 1:length(scenes(i).finish)
            finish_event_stream = getfield(trial_data.events, scenes(i).finish(j).stream);
            finish_event_labels = lower(finish_event_stream.label);
            finish_event_inds = find(finish_event_labels == lower(scenes(i).finish(j).tag));
            finish_event_time = finish_event_stream.timestamp_ms(finish_event_inds);
            for k = 1:length(finish_event_inds)
                scenes_log(i).finish(j).type(k).label = scenes(i).finish(j).tag;
                scenes_log(i).finish(j).type(k).ind = finish_event_inds(k);
                scenes_log(i).finish(j).type(k).time = finish_event_time(k);

                scenes_mat(mat_ind).name = scenes(i).name;
                scenes_mat(mat_ind).stream = scenes(i).finish(j).stream;
                scenes_mat(mat_ind).isbegin = false;
                scenes_mat(mat_ind).ispeak = false;
                scenes_mat(mat_ind).isfinish = true;
                scenes_mat(mat_ind).isdeath = false;
                scenes_mat(mat_ind).label = scenes(i).finish(j).tag;
                scenes_mat(mat_ind).ind = finish_event_inds(k);
                scenes_mat(mat_ind).time = finish_event_time(k);
                mat_ind = mat_ind+1;
            end
        end
    end

    for i = 1:length(trial_data.events.player_controlled.timestamp_ms)
        if strcmp(lower(extractBefore(trial_data.events.player_controlled.label(i),"-")),"death")

                % TODO: find out which scene by checking label
                scenes_mat(mat_ind).name = "unknown";
                scenes_mat(mat_ind).stream = "character";
                scenes_mat(mat_ind).isbegin = false;
                scenes_mat(mat_ind).ispeak = false;
                scenes_mat(mat_ind).isfinish = false;
                scenes_mat(mat_ind).isdeath = true;
                scenes_mat(mat_ind).label = trial_data.events.player_controlled.label(i);
                scenes_mat(mat_ind).ind = i;
                scenes_mat(mat_ind).time = trial_data.events.player_controlled.timestamp_ms(i);
                mat_ind = mat_ind+1;
        end
    end

    if length(scenes_mat) ~= 0
        scenes_played = struct2cell(scenes_mat);
    else
        scenes_played = {"__________";"__________";0;0;0;0;"__________";0;0;0};
    end
    sz = size(scenes_played);
    % Convert to a matrix
    scenes_played = reshape(scenes_played, sz(1), []);      % Px(MxN)
    % Make each field a column
    scenes_played = scenes_played';                         % (MxN)xP
    % Sort by first field "name"
    scenes_played = sortrows(scenes_played, 9);

    game_table = table(0, "__________", 'VariableNames', {'timestamp_ms', 'label'});



    [len,~] = size(scenes_played);
    for i = 1:len
        if strcmp(scenes_played{i,1}, "unknown")
           scenes_played{i,1} = scenes_played{i-1,1}; 
        end
    end

    %column for start of each scene
    scenes_played{1,10} = 1;
    for i = 2:len
        if ~(strcmp(scenes_played{i,1}, scenes_played{i-1,1}))
            scenes_played{i,10} = 1;
        else
            scenes_played{i,10} = 0;
        end
    end

    [len,~] = size(scenes_played);
    i = 2;
    while i < len
        if strcmpi(scenes_played{i,7}, "light-river-2") && strcmpi(scenes_played{i-1,7}, "light-river-1")
            scenes_played(i,:) = [];
            i = i -1;
            len = len -1;
        end
        i = i+1;
    end

    [len,~] = size(scenes_played);
    i = 2;
    while i < len
        if strcmpi(scenes_played{i,7}, "light-river-1") && strcmpi(scenes_played{i-1,7}, "splash")
            scenes_played(i,:) = [];
            i = i - 1;
            len = len -1;
        end
        i = i+1;
    end
end
