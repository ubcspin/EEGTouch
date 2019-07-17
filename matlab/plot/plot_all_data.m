% Plots FSRs, feeltrace on interview into big printable image.

%TODO: make this a function
%TODO: refactor helpers

% Load directories and data.
function the_plot = plot_all_data(local_paths, trial_data)
    clf;
    the_plot = figure(1);
    confirm_required_data_present(trial_data);

    %% FIRST SUBPLOT: feeltrace and calibrated words

    % plot in sections 1-12 of 29-section grid
    subplot(29,1,[2 3 4 5 6 7 8 9 10 11 12]);
    hold on;
    grid on;
    PLOT1_MAXIMUM_VAL = 10;

    %plot fsrs
    fsr_plot = plot_fsr(trial_data.fsr, PLOT1_MAXIMUM_VAL);
    gridlines_with_midpoint = plot_gridlines_with_midpoint();

    %plot joystic
    joystick_plot = plot_joystick(trial_data.joystick, PLOT1_MAXIMUM_VAL);

    % line plot the calibrated words
    
    [calibrated_words_plot, calibrated_words_points, calibrated_words_words] = plot_calibrated_words(trial_data.calibrated_words, PLOT1_MAXIMUM_VAL);

    % set range to min and max of calibrated words
    ylim([0,PLOT1_MAXIMUM_VAL*2]);
    yticks([PLOT1_MAXIMUM_VAL,PLOT1_MAXIMUM_VAL*2]);
    emotion_ylabel = 'Reported emotion';
    emotion_ylabel = [emotion_ylabel newline 'Relieved                                             Stressed'];
    ylabel(emotion_ylabel,'FontSize',14);
    yticklabels([]);
    
    % x ticks every 15 seconds
    plot1_x_axis = x_axis_no_labels(trial_data.fsr.timestamp_ms(end));

    yyaxis right
    ax = get(gcf,'CurrentAxes');
    ax.YAxis(2).Color = 'black';
    fsr_ylabel = 'Min                                             Max';
    fsr_ylabel = [fsr_ylabel newline 'Keypress intensity'];

    ylabel(fsr_ylabel,'FontSize',14);
    ytickangle(90);
    yticks([10 20]);
    ylim([0,20]);
    yticklabels([]);
    ax = gca;
    ax.GridColor = [0, 0, 0];
    set(gca,'Layer','top');

    hold off;

    %% SUBPLOT 2: interview text

    subplot(29,1,[13 14 15 16 17]);
    hold on;
    grid on;
    gridlines_2 = plot_gridlines();
    
    % array of ones for 1D interview plot at controlled height
    %interview_ones = ones(length(trial_data.interview.timestamp_ms),1);
    % array of number + staggered space strings for interview x-labels
    %interview_nums_num = (1:length(trial_data.interview.timestamp_ms)).';
    %interview_nums = arrayfun(@(x) strcat(num2str(x),convertCharsToStrings(blanks(mod(x,3)*2))), interview_nums_num,'UniformOutput',false);
    interview_words_x_textpositions = trial_data.interview.timestamp_ms/get_ms_per_min();
    interview_words_y_textpositions = zeros(length(trial_data.interview.timestamp_ms),1);
    
    wrapped_text = arrayfun(@(c) textwrap(c,30), trial_data.interview.label,'UniformOutput',false);
    interview_text = text(interview_words_x_textpositions, interview_words_y_textpositions, wrapped_text,'Margin',0.001,'BackgroundColor',[1 1 1],'FontName',get_small_text_font());
    set(interview_text,'Rotation',90);
    set(interview_text,'FontSize',13);
    ylabel('Interview','FontSize',15);

    yticks([]);
    plot2_x_axis = x_axis_no_labels(trial_data.fsr.timestamp_ms(end));
%     xlim([0 get_longest_trial_length_min()]);
%     xticks(0 : 0.25 : ceil(trial_data.fsr.timestamp_ms(end)/get_ms_per_min()));
%     xticklabels([]);
%     xtickangle(90);
%     ax = gca;
%     ax.TickLength = [0 0];

    hold off;

    %% SUBPLOT 3: event labels
    subplot(29,1,[18 19 20 21 22]);
    hold on;
    grid on;

    tickbars = (0 : 0.25 : ceil(trial_data.fsr.timestamp_ms(end)/get_ms_per_min()));
    tickhei = ones(length(tickbars),1)*20;
    gridcol = [0.80 0.80 0.80];
    bar(tickbars,tickhei,1/60,'FaceColor',gridcol,'EdgeColor',gridcol);

    ytickangle(90);
    yticks([]);
    ax = gca;
    set(ax,'FontSize',12);
    grid on;
    % game events
    game_visual_events_text = plot_events(trial_data.events.game_controlled_visual, 0.1, 'VISUAL   ', [0 0 0]);
    game_sound_events_text = plot_events(trial_data.events.game_controlled_sound, 1.1, 'SOUND    ', [124/255 10/255 2/255]);
    player_events_text = plot_events(trial_data.events.player_controlled, 2.1, 'PLAYER   ', [17/255 30/255 108/255]);

    ylim([0 3]);
    plot3_x_axis = x_axis_no_labels(trial_data.fsr.timestamp_ms(end));
    ylabel('Events','FontSize',15);

     %% SUBPLOT 4: frames
    subplot(29,1,[23 24 25 26]);
    hold on;
    grid on;
    if sum(contains(fieldnames(trial_data),"frames")) == 0
        pull_vid_frames;
        save_file;
    end
    for i = 1:length(trial_data.frames.frames)
        image([(i-1)/4 i/4],[0 1], imrotate(trial_data.frames.frames(i).cdata,90));
    end
    ylim([0 1]);
    yticks([]);
    xlim([0 get_longest_trial_length_min()]);
    xticks(0 : 0.25 : ceil(trial_data.fsr.timestamp_ms(end)/get_ms_per_min()));
    xticklabels([]);
    %starttick = 0.25;
    %xticklabels(vertcat(strings(1,starttick/0.25), datestr(datetime((starttick/24/60:1/24/60/60*15:1/24/60*ceil(trial_data.joystick.timestamp_ms(end)/MS_PER_MIN)),'ConvertFrom','datenum'),'MM:SS')));
    %xtickangle(90); 
    %ax = gca;
    %ax.XGrid = 'on';
    % set(ax,'FontSize',30);
    % set(ax,'linewidth',1);
    %hold off;

    %% SUBPLOT 5: sceneset

    subplot(29,1,[28 29]);
    hold on;
    grid off;

    colors = [[0, 0.4470, 0.7410]];
    colors = [colors; 	[0.8500, 0.3250, 0.0980]];
    colors = [colors; 	[0.9290, 0.6940, 0.1250]];
    colors = [colors;   [0.4940, 0.1840, 0.5560]];
    colors = [colors; 	[0.4660, 0.6740, 0.1880]];
    colors = [colors; 	[0.3010, 0.7450, 0.9330]];
    colors = [colors; 	[0.6350, 0.0780, 0.1840]];
    colors = [colors; 	[0, 0, 1]];
    colors = [colors; 	[1, 0, 0]];
    colors = [colors; 	[0.75, 0.75, 0]];
    colors = [colors; 	[0.25, 0.25, 0.25]];

    scenes_cell = trial_data.scenes;

    times = [scenes_cell{:,9}]';
    isstart = [scenes_cell{:,3}]';
    ispeak = [scenes_cell{:,4}]';
    isfinish = [scenes_cell{:,5}]';
    isdeath = [scenes_cell{:,6}]';
    isfirst = [scenes_cell{:,10}]';
    labels = [scenes_cell{:,1}]';

    scenes = get_scenes_list();
    
    for i = 1:length(scenes)
        indices = find([scenes_cell{:,1}]' == scenes(i).name);
        times = [scenes_cell{:,9}]';
        if ~isempty(indices)
            plot([times(indices(1))/get_ms_per_min(),times(indices(end))/get_ms_per_min()], [1-0.25+rem(i,2)*0.5,1-0.25+rem(i,2)*0.5],'LineWidth',5,'Color',colors(i,:));
        end
        for j = 1:length(indices)
            if isfirst(indices(j))
                if strcmp(labels(indices(j)),'Far truck')
                    p_text = 'Far';
                    p_text = [p_text newline 'truck'];
                    p_pos = times(indices(j))/get_ms_per_min()+4/60;
                else
                    p_text = labels(indices(j));
                    p_pos = times(indices(j))/get_ms_per_min()+3/60;
                end
                tt = text(p_pos, 1.3-0.25+rem(i,2)*0.5, p_text,'Color',colors(i,:),'FontSize',14,'FontName',get_small_text_font(),'BackgroundColor',[1 1 1],'Margin',0.01);
                tt(1).FontWeight = 'bold';
                tt(1).Rotation = 90;
                %text(times(indices(j))/MS_PER_MIN, 2, labels(indices(j)),'Color',colors(i,:),'FontSize',10);
            end
            if isstart(indices(j))
                %text((times(indices(j))-2500)/MS_PER_MIN,1,'>');
                %scatter((times(indices(j))-2500)/MS_PER_MIN,1-0.25+rem(i,2)*0.5,5,'Marker','>','MarkerEdgeColor',colors(i,:),'LineWidth',2);
                plot([(times(indices(j)))/get_ms_per_min()-2/60,(times(indices(j)))/get_ms_per_min()], [1-0.25+rem(i,2)*0.5+0.4,1-0.25+rem(i,2)*0.5], 'LineWidth',3,'Color',colors(i,:));
                plot([(times(indices(j)))/get_ms_per_min()-2/60,(times(indices(j)))/get_ms_per_min()], [1-0.25+rem(i,2)*0.5-0.4,1-0.25+rem(i,2)*0.5], 'LineWidth',3,'Color',colors(i,:));
                %text((times(indices(j)))/get_ms_per_min(),1-0.25+rem(i,2)*0.5,'>','FontSize',40,'HorizontalAlignment','right','Color',colors(i,:),'FontName','Gill Sans MT Condensed');
                %scatter((times(indices(j)))/get_ms_per_min(),1-0.25+rem(i,2)*0.5,5,'Marker','.','MarkerEdgeColor',[0 0 0],'LineWidth',1);
                %scatter(times(indices(j))/get_ms_per_min(),1,10,'Marker','.','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 0 0], 'LineWidth', 1);
            elseif ispeak(indices(j))
                scatter(times(indices(j))/get_ms_per_min(),1-0.25+rem(i,2)*0.5,20,'Marker','.','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 0 0], 'LineWidth', 3);
            elseif isfinish(indices(j))
                %
                plot([(times(indices(j)))/get_ms_per_min(),(times(indices(j)))/get_ms_per_min()+2/60], [1-0.25+rem(i,2)*0.5,1-0.25+rem(i,2)*0.5+0.4], 'LineWidth',3,'Color',colors(i,:));
                plot([(times(indices(j)))/get_ms_per_min(),(times(indices(j)))/get_ms_per_min()+2/60], [1-0.25+rem(i,2)*0.5,1-0.25+rem(i,2)*0.5-0.4], 'LineWidth',3,'Color',colors(i,:));
                %text((times(indices(j)))/get_ms_per_min(),1-0.25+rem(i,2)*0.5,'>','FontSize',40,'HorizontalAlignment','right','Color',colors(i,:),'FontName','Gill Sans MT Condensed');
                %scatter((times(indices(j)))/get_ms_per_min(),1-0.25+rem(i,2)*0.5,5,'Marker','.','MarkerEdgeColor',[0 0 0],'LineWidth',1);
                %
                %scatter((times(indices(j))+2500)/get_ms_per_min(),1-0.25+rem(i,2)*0.5,5,'Marker','<','MarkerEdgeColor',colors(i,:),'LineWidth',2);
                %scatter(times(indices(j))/get_ms_per_min(),1,10,'Marker','.','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 0 0], 'LineWidth', 1);
                %scatter(times(indices(j))/get_ms_per_min(),1,40,'Marker','<','MarkerEdgeColor',colors(i,:),'MarkerFaceColor',colors(i,:));
            elseif isdeath(indices(j))
                scatter(times(indices(j))/get_ms_per_min(),1-0.25+rem(i,2)*0.5,10,'Marker','x','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 0 0],'LineWidth',3);
            end
        end
    end


    xlim([0 get_longest_trial_length_min()]);
    % x ticks every 15 seconds
    xticks(0 : 0.25 : ceil(trial_data.fsr.timestamp_ms(end)/get_ms_per_min()));
    starttick = 0.25;
    xticklabels(vertcat(strings(1,starttick/0.25), datestr(datetime((starttick/24/60:1/24/60/60*15:1/24/60*ceil(trial_data.joystick.timestamp_ms(end)/get_ms_per_min())),'ConvertFrom','datenum'),'MM:SS')));
    xtickangle(90); 
    ax = gca;
    ax.XGrid = 'on';
     set(ax,'FontSize',30);
     set(ax,'linewidth',1);
    xstring = join(repmat(strcat("                                                            P", trial_data.scalars.trial_number),1,32));
    xlabel(xstring,'FontSize', 11);
    hold off;
    yticks([]);
    ylim([0 2]);
    ylabel('Scenes','FontSize',15);

    %% PRINT AND SAVE
    the_plot.PaperUnits = 'inches';
    the_plot.PaperPosition = [0 0 110 16];
    print(fullfile(local_paths.processed_directory,['data_plot' char(trial_data.scalars.trial_number)]),'-dpng','-r0');
end
    
function is_data_present = confirm_required_data_present(trial_data)
    is_data_present = false;
    % If data to plot is not available, get it.
    if ~any(ismember(fields(trial_data),{'fsr'})) 
       [trial_data.fsr, trial_data.scalars.sync_frame, trial_data.scalars.frame_rate] = align_fsr_and_vidsync(local_paths, trial_data);
    end
    if ~any(ismember(fields(trial_data),{'joystick'}))
       trial_data.joystick = align_joystick(local_paths, trial_data);
    end
    if ~any(ismember(fields(trial_data),{'interview'}))
       trial_data.interview = align_interview(local_paths, trial_data);
    end
    is_data_present = true;
end
    
function fsr_plot = plot_fsr(fsr_data, plot_maximum_val)
     fsr_plot_colour = [0.8 0.8 0.8];
     max_fsr = max([fsr_data.A0  fsr_data.A1  fsr_data.A2 fsr_data.A3 fsr_data.A4],[],2);
     fsr_plot = area(fsr_data.timestamp_ms/get_ms_per_min(), max_fsr/1023*plot_maximum_val*2, 'FaceColor',fsr_plot_colour,'EdgeColor',fsr_plot_colour);
end

function [calibrated_words_plot, calibrated_words_points, calibrated_words_words] = plot_calibrated_words(calibrated_words_data, PLOT1_MAXIMUM_VAL)
    calibrated_words_plot_colour = [255/255 129/255 0/255];
    calibrated_words_plot_linewidth = 2;
    calibrated_words_plot_marker = '*';
    calibrated_words_marker_size = 5;
    calibrated_words_plot = plot(calibrated_words_data.timestamp_ms/get_ms_per_min(), calibrated_words_data.calibrated_values+PLOT1_MAXIMUM_VAL, 'Color', calibrated_words_plot_colour, 'LineWidth', calibrated_words_plot_linewidth);
    % scatter plot the calibrated words
    calibrated_words_points = scatter(calibrated_words_data.timestamp_ms/get_ms_per_min(), calibrated_words_data.calibrated_values+PLOT1_MAXIMUM_VAL,calibrated_words_marker_size,'Marker',calibrated_words_plot_marker,'LineWidth',calibrated_words_plot_linewidth,'MarkerEdgeColor',calibrated_words_plot_colour);
    % set positions for calibrated words text
    calibrated_words_x_textpositions = calibrated_words_data.timestamp_ms/get_ms_per_min();
    calibrated_words_y_textpositions = calibrated_words_data.calibrated_values+PLOT1_MAXIMUM_VAL;
    % plot calibrated words text
    calibrated_words_words = text(calibrated_words_x_textpositions, calibrated_words_y_textpositions, cellstr(calibrated_words_data.emotion_words));
    set(calibrated_words_words,'Rotation',90);
    set(calibrated_words_words,'FontSize',13);
    set(calibrated_words_words,'FontWeight','bold');
end

function gridlines = plot_gridlines_with_midpoint()
    gridlines = struct;
    
    %horizontal gridlines
    tickbars = (0 : 0.25 : get_longest_trial_length_min());
    tickhei = ones(length(tickbars),1)*20;
    gridcol = [0.60 0.60 0.60];
    gridlines.horizontal = bar(tickbars,tickhei,1/60,'FaceColor',gridcol,'EdgeColor',gridcol);
    
    %vertical gridlines
     gridlines.top = plot([0 22],[10 10],'Color',gridcol,'LineWidth',1);
     %plot([0 22],[10 10],'Color',gridcol,'LineWidth',1);
     gridlines.bottom = plot([0 22],[0 0],'Color',gridcol,'LineWidth',1);
end

function gridlines = plot_gridlines()
    tickbars = (0 : 0.25 : get_longest_trial_length_min());
    tickhei = ones(length(tickbars),1)*20;
    gridcol = [0.80 0.80 0.80];
    gridlines = bar(tickbars,tickhei,1/60,'FaceColor',gridcol,'EdgeColor',gridcol);
end

function joystick_plot = plot_joystick(joystick_data, plot_maximum_val)
    max_joystick = max(joystick_data.joystick);
    joystick_plot_colour = [21/255 104/255 237/255];
    joystick_plot_linewidth = 2;
    joystick_plot = plot(joystick_data.timestamp_ms/get_ms_per_min(),joystick_data.joystick/max_joystick*plot_maximum_val*2,'Color',joystick_plot_colour,'LineWidth',joystick_plot_linewidth);
end

function the_x_axis = x_axis_no_labels(end_timestamp)
    xlim([0 get_longest_trial_length_min()]);
    xticks(0 : 0.25 : ceil(end_timestamp/get_ms_per_min()));
    xticklabels([]);
    xtickangle(90); 
    the_x_axis = gca;
    the_x_axis.XGrid = 'on';
    the_x_axis.TickLength = [0 0];
end

function events_text = plot_events(events_stream, y_position,events_stream_name_string,events_stream_colour)
    EVENT_NAME_LABEL_POSITION = 7/60;
    
    events_x_textpositions = vertcat(EVENT_NAME_LABEL_POSITION, events_stream.timestamp_ms/get_ms_per_min());
    events_y_textpositions = repmat(y_position, length(events_stream.timestamp_ms)+1, 1);
    wrapped_text = char(events_stream.label);
    wrapped_text = wrapped_text(:,1:9);
    wrapped_text = vertcat(events_stream_name_string, wrapped_text);
   
    events_text = text(events_x_textpositions, events_y_textpositions, wrapped_text,'Color',events_stream_colour,'FontName',get_small_text_font());
    set(events_text,'Rotation',90);
    set(events_text,'FontSize',12);
end

function small_text_font = get_small_text_font()
    if find(strcmp(listfonts, 'Times New Roman'))
        small_text_font = 'Times New Roman';
    elseif find(strcmp(listfonts, 'Palatino'))
        small_text_font = 'Palatino'; 
    else
        small_text_font = '';
    end
end

function ms_per_min = get_ms_per_min()
    ms_per_min = 60000;
end

function longest_trial_length_min = get_longest_trial_length_min()
    longest_trial_length_min = 22;
end
