function [trial_data, labelfile] = correct_events(trial_data, labelfile)
    
    gameeventcount = height(trial_data.events.game_controlled_visual);
    charactereventcount = height(trial_data.events.player_controlled);
    soundeventcount = height(trial_data.events.game_controlled_sound);
    
    labelcount = height(labelfile);
    
   for i = 1:gameeventcount
        
        trial_data.events.game_controlled_visual{i, 3} = 0;

        gamelabel = trial_data.events.game_controlled_visual{i, 2};
   
        for j = 1:labelcount
           
            gameoriginal = labelfile{j,1};
            gamenew = labelfile{j,2};
            
            if strcmp(gamenew,'')
                continue
                
            end
            
            if strcmp(gamelabel, gameoriginal)
                
                trial_data.events.game_controlled_visual{i, 2} = gamenew;
                trial_data.events.game_controlled_visual{i, 3} = 1;
                labelfile{j, 3} = labelfile{j, 3} + 1;
                disp('gamechange')
                
                break
                
            end
            
        end
        
   end
    
   for k = 1:charactereventcount
        trial_data.events.player_controlled{i, 3} = 0;
        characterlabel = trial_data.events.player_controlled{k, 2};
        
        for l = 1:labelcount
           
            characteroriginal = labelfile{l,1};
            characternew = labelfile{l,2};
            
            if strcmp(characternew,'')
                
                continue
                
            end
            
            if strcmp(characterlabel, characteroriginal)
                
                trial_data.events.player_controlled{k, 2} = characternew;
                trial_data.events.player_controlled{k, 3} = 1;
                labelfile{l, 3} = labelfile{l, 3} + 1;
                disp('characterchange')
                
                break
                
            end
            
        end
        
   end
    
   for m = 1:soundeventcount
        trial_data.events.game_controlled_sound{i, 3} = 0;
        soundlabel = trial_data.events.game_controlled_sound{m, 2};
        
        for n = 1:labelcount
           
            soundoriginal = labelfile{n,1};
            soundnew = labelfile{n,2};
            
            if strcmp(soundnew,'')
                
                continue
                
            end
            
            if strcmp(soundlabel, soundoriginal)
                
                trial_data.events.game_controlled_sound{m, 2} = soundnew;
                trial_data.events.game_controlled_sound{m, 3} = 1;
                labelfile{n, 3} = labelfile{n, 3} + 1;
                disp('soundchange')
                
                break
                
            end
            
        end
        
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% for i = 1:labelcount
%        
%        original = labelfile{i,1};
%        new = labelfile{i,2};
%            
%        if strcmp(new,'')
%                
%            continue
%                
%        end
%        
%        for g = 1:gameeventcount
%        
%            gamelabel = trial_data.events.game_controlled_visual{g, 2};
%            if strcmp(gamelabel, original)
%                
%                trial_data.events.game_controlled_visual{i, 2} = new;
%                trial_data.events.game_controlled_visual{i, 3} = 1;
%                labelfile{i, 3} = labelfile{i, 3} + 1;
%                
%            end
%              
%        end
%        
%        for c = 1:charactereventcount
%            
%            
%        end
%        
%        for s = 1:soundeventcount
%            
%            
%        end
%    
%        
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 