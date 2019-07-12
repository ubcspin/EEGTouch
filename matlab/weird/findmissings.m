events.game = strings(eeglen,1);
len = length(processed_data.events.game.timestamp_ms);
for i = 1:len
    events.game(processed_data.events.game.timestamp_ms(i)) = processed_data.events.game.label(i);
end

events.game = standardizeMissing(events.game,"");
events.game = fillmissing(events.game,'nearest');