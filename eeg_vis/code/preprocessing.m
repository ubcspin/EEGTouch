% Script for preprocessing EEG data 

% IMPORTANT: The dataset saved by this file contains the ICA weights, but the 
% component rejection must be done on hand before any visualization scripts are run.
% 
% Requirements:
% 	- Load the dataset of interest by calling eeglab on the command line, 
%   then select "File"->"Import data"->"Using EEGLAB functions and plugins"->"From 
%   Netstation Matlab Files". Select the eeg_data.mat file, sample at 1000Hz
% 	- Needs the clean_rawdata eeglab extension to be installed

% Ensure that the ../data/Pxx folder also contains:
%       - the eeg_data.mat file, which is the raw data file that contains the evt_DIN1 array
%       - the channel_locations.sfp file 

% Parameters to be set by the user
participant = "P22_ASR20"; % participant number in Pxx format; eg. P09
din_num = 2; % which DIN number to use
asr_param = 20; % standard deviation for automatic data cleaning (20 recommended)
    
% Start preprocessing:
fprintf('Begin preprocessing\n');

f = fileparts(pwd);
% .mat file containing the dataset and DIN times
raw_data = fullfile(f,'data',participant,'eeg_data.mat'); 
% file with channel locations 
channel_locs = char(fullfile(f,'data',participant,'channel_locations.sfp')); 
% location to save the processed file
dataset_path = char(fullfile(f,'data',participant));

% To load up the DIN times
load(raw_data);
DIN = evt_DIN1{2,din_num}/1000;

% checkset checks the consistency of fields of an EEG dataset; built-in
EEG = eeg_checkset( EEG );
% removes the pre-DIN part of the EEG to align with other data
EEG = pop_select( EEG,'notime',[1 DIN] );
EEG = eeg_checkset( EEG );
% adds the channel locations
EEG = pop_chanedit(EEG, 'load',{channel_locs 'filetype' 'autodetect'});
EEG = eeg_checkset( EEG );
% downsample to 250Hz for speed; we are not interested in high frequencies
EEG = pop_resample( EEG, 250);
% filter out frequencies below 1Hz and above 50Hz
EEG = pop_eegfiltnew(EEG, 1,50);
EEG = eeg_checkset( EEG );
% keep a copy of the old dataset before running clean_rawdata
originalEEG = EEG;
% use clean_rawdata to remove bad channels and correct bursts
EEG = clean_rawdata(EEG, 5, [0.25 0.75], 0.8, 4, asr_param, -1); 
EEG = eeg_checkset( EEG );
% use the old dataset's channel locations to interpolate the removed channels
EEG = pop_interp(EEG, originalEEG.chanlocs, 'spherical');
EEG = eeg_checkset( EEG );
% rereference to average
EEG = pop_reref( EEG, []);
EEG = eeg_checkset( EEG );
% run ICA decomposition with pca enabled to account for lower rank
dataRank = rank(EEG.data);
EEG = pop_runica(EEG, 'extended',1,'interupt','on','pca',dataRank);
EEG = eeg_checkset( EEG );
% save to file
EEG = pop_saveset(EEG, 'filename','Processed_ICA.set','filepath',dataset_path);
EEG = eeg_checkset( EEG );

eeglab redraw;

% TODO: use pop_comments to keep track of what happened; see dataset info later
% EEG.comments = pop_comments(EEG.comments,'','Dataset was highpass filtered 
% at 1 Hz and rereferenced.',1);

