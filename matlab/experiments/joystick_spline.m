load_all_processed;

for i = 1:size(all_data,1)
    pfile = all_data{i,1};
    
    if ~isempty(pfile)
        fprintf('Extracting event {x} joystick data from participant %d...\n', i);
        
        if i == 2
            x = pfile.joystick.timestamp_ms;
            y = pfile.joystick.joystick;
            
            xe = pfile.events.game_controlled_visual.timestamp_ms;
            
            % NEED TO INSTALL CURVE FITTING TOOLBOX FOR "fit" function. 
            
            % 1e-16 is more smooth. closer to 1 is less smooth. 
            [curve, goodness, output] = fit(x, y,'smoothingspline', 'SmoothingParam', 1e-8);
%             plot(xe, ones(size(xe, 1)) * 5, '-.or', x, y);

            % NOTE: DBSCAN as lazy estimate for now, probably better to do
            % some form of KDE clustering/mean-shift based clustering 
            idx = dbscan(xe, 20000, 2);

            figure 
            hold on 
            axis([min(x), max(x), min(y), max(y)])
            plot(curve);
            
            gscatter(xe, ones(size(xe, 1)) * 5, idx);
            
            xlabel('Time');
            ylabel('Joystick');
            
%             gscatter(xe, ones(size(xe, 1)), idx);
            
            
            
            break
        end
    end
end