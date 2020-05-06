%% LOAD ALL PROCESSED DATA

labelswitch = readtable('labelswitch.csv');

%[all_data{2,1}, labelswitch] = correct_events(all_data{2,1}, labelswitch);

if  exist('all_data', 'var') == 1
    disp('Using pre-existing all_data variable.');
    return;
end 

disp('Could not find existing all_data variable. Loading from disk...');

ptotal = 23;
all_data = cell(23, 1);

for i = 1:ptotal
    str_i = sprintf('%02d',i);
    fprintf('Loading data from participant %d... ', i);
    try 
        pfile = load(strcat('processed_data_pxx/processed_data_p', str_i, '/processed_data.mat'));
        all_data{i,1} = rename_fields(pfile.processed_data);
        [all_data{i,1}, labelswitch] = correct_events(all_data{i,1}, labelswitch);
        %[all_data{2,1}, labelswitch] = correct_events(all_data{2,1}, labelswitch);
        fprintf('SUCCESS!\n');
    catch ex
        fprintf('FAILED.\n');
    end 
end

%change p17 player_controlled death(75, 82, 96)  => catch, catch,
%death-shot

if strcmp(all_data{17, 1}.events.player_controlled{75,2}, "death")
    all_data{17,1}.events.player_controlled{75, 2} = "catch";
    all_data{17,1}.events.player_controlled{75, 3} = 1;
end
if strcmp(all_data{17, 1}.events.player_controlled{82,2}, "death")
    all_data{17,1}.events.player_controlled{82, 2} = "catch";
    all_data{17,1}.events.player_controlled{82, 3} = 1;
end
if strcmp(all_data{17, 1}.events.player_controlled{96,2}, "death")
    all_data{17,1}.events.player_controlled{96, 2} = "death-shot";
    all_data{17,1}.events.player_controlled{96, 3} = 1;
end

%change p22 game_controlled_sound truck shot(44,45)  => road shots start,
%road shot
if strcmp(all_data{22, 1}.events.game_controlled_sound{44,2}, "truck shot")
    all_data{22,1}.events.game_controlled_sound{44, 2} = "road shots start";
    all_data{22,1}.events.game_controlled_sound{44, 3} = 1;
end
if strcmp(all_data{22, 1}.events.game_controlled_sound{45,2}, "truck shot")
    all_data{22,1}.events.game_controlled_sound{45, 2} = "road shot";
    all_data{22,1}.events.game_controlled_sound{45, 3} = 1;
end

clearvars str_i i ptotal pfile ex

