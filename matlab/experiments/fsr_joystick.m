load_all_processed;

for i = 1:size(all_data,1)
    pfile = all_data{i,1};
    
    if ~isempty(pfile)
        fprintf('Extracting fsr {x} joystick data from participant %d...\n', i);

        % For now, only do it for participant 2. 
        if i == 4
            fsr_abs = max( ...
                [pfile.fsr.A0, ...
                    pfile.fsr.A1, ...
                    pfile.fsr.A2, ...
                    pfile.fsr.A3, ...
                    pfile.fsr.A4], [], 2);

            f1 = figure('Name', 'Max-FSR');
            plot(fsr_abs);
            
            % if data point is 0, does it make sense to connect the 
            % data points together when analyzing? Or does it make more 
            % sense to default it at 0. 
            
            
            % NEED TO INSTALL SIGNAL PROCESSING TOOLBOX FOR HIGH PASS
            % FILTER TO WORK. STEPS: Apps -> Get More Apps -> Search for
            % "Signal Processing Toolbox" -> Install/Sign in to Install
            h_fsr_abs = highpass(fsr_abs, 0.5);
            
            
            f2 = figure('Name', 'Joystick'); 
            plot(pfile.joystick.joystick);
            
            % try doing a high-pass filter on Joystick. 
            h_joystick = highpass(pfile.joystick.joystick, 0.5);
%             fh = figure('Name', 'Result');
%             plot(result);
            
            f3 = figure('Name', 'Cross-Correlation');
            r = xcorr(h_fsr_abs, h_joystick);
            plot(r)
        end
        
    end
    
    % For each participant, we want to check how closely their FSR data 
    % correlates with their joystick data. There might be some time delay,
    % so we apply a cross-correlation method to the two time series.
    
    % KC NOTE 03/30/2020: WAS TRYING TO DO THIS, but didn't finish.
    % cross-correlation needs to be tweaked/maybe isn't the right approach
    % for this. 
    
    % How do we interpret the cross-correlation data??
    
    
end

clearvars -except all_data