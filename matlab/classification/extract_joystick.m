
function [abs, variance, slp, slp2] = extract_joystick(timeseries, timestamps, low_off, high_off) 
    abs = zeros(height(timestamps), 1);
    variance = zeros(height(timestamps), 1);
    slp = zeros(height(timestamps), 1);
    slp2 = zeros(height(timestamps), 1);

    for j = 1:height(timestamps)
        ts = timestamps{j,1};
        rows = timeseries.timestamp_ms <= ts + high_off & ...
            timeseries.timestamp_ms >= ts - low_off;
        joystick_in_window = timeseries(rows, {'timestamp_ms', 'joystick'});
        if size(joystick_in_window, 1) > 0
            abs(j,1) = max(joystick_in_window.joystick);
            variance(j,1) = var(joystick_in_window.joystick);
            
            % Calculate average slope in window
            slp(j,1) = (joystick_in_window.joystick(end) - joystick_in_window.joystick(1)) ...
                / (joystick_in_window.timestamp_ms(end) - joystick_in_window.timestamp_ms(1));
            
            % Calculate individual slopes in window and average
            slopes = diff(joystick_in_window.joystick)./diff(joystick_in_window.timestamp_ms);
            slp2(j,1) = mean(slopes);
        else 
            abs(j,1) = NaN;
            variance(j,1) = NaN;
            slp(j,1) = NaN;
            slp2(j,1) = NaN;
        end 
    end 
    return;
end