function trial_data = rename_fields(trial_data)
    trial_fieldnames = fieldnames(trial_data);
    if ~isempty(trial_fieldnames)
        for i = 1:numel(trial_fieldnames)
            if strcmp(trial_fieldnames{i},'feeltrace')
                trial_data.joystick = trial_data.feeltrace;
                trial_data = rmfield(trial_data,'feeltrace');
            elseif strcmp(trial_fieldnames{i},'events')
                trial_events_fieldnames = fields(trial_data.events);
                for j = 1:numel(trial_events_fieldnames)
                    if strcmp(trial_events_fieldnames{j}, 'game')
                        trial_data.events.game_controlled_visual = trial_data.events.game;
                        trial_data.events = rmfield(trial_data.events,'game');
                    elseif strcmp(trial_events_fieldnames{j},'sound')
                        trial_data.events.game_controlled_sound = trial_data.events.sound;
                        trial_data.events = rmfield(trial_data.events,'sound');
                    elseif strcmp(trial_events_fieldnames{j},'character')
                        trial_data.events.player_controlled = trial_data.events.character;
                        trial_data.events = rmfield(trial_data.events,'character');
                    end
                end
            end
        end
    end
end