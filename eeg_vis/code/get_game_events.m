% Script for extracting game events from processed_data.mat file

% Ensure that the ../data/Pxx folder contains:
%       - processed_data.mat, which contains the processed_data.events.game table

% Parameter to be set by the user
participant = "P09"; % participant number in Pxx format; eg. P09

f = fileparts(pwd);
pfolder = fullfile(f,'data',participant,'processed_data.mat');

load(pfolder);

game_ev = processed_data.events.game;
game_ev = table2array(game_ev);

game_events = [game_ev(:,2),str2double(game_ev(:,1))];
game_events = array2table(game_events);

gfolder = fullfile(f,'data',participant,'game_events.mat');

save(gfolder,'game_events');