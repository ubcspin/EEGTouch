## Getting Started
1. Prereq: `conda>=4.8`
2. Setup virtual environment with all the required dependencies with
```
conda env create -n <give-a-name-to-the-env> -f environment.yml
```
3. Activate the virtual environment with `conda activate <name-of-env>`.
To deactivate the env later `conda deactivate`
4. With the environment activated, start a jupyter session with `jupyter lab`

## EEG Preprocessing

### EEG filtering + EOG removal with ICA
*Code files*
- `EEGTouch/eeg_python/Preoprocess_filter+artifact_removal.ipynb`
*Input files*
- eeg.mat files stored in `converted_data` on spin server
*Output files*
Figures related to eye movement and ICA analysis saved at `EEGTouch/eeg_python/figures/eog`
Preprocessed eeg csv files saved at `EEGTouch/eeg_python/data/filtered_eeg (named as p#_eeg.csv)` (dimension: timestamps x 64)

1. Download `converted_data` from spin server at `/ubc/cs/research/imager/project/spin/proj/eeg/converted_data`. This folder is organiazed by participant number. Within each participant folder, there is a `eeg.mat` and a `feeltrace.mat`
2. Open `EEGTouch/eeg_python/Preoprocess_filter+artifact_removal.ipynb` from jupyter lab. Modify the lines
```
path_to_raw_eeg = '../../converted_data'
path_to_figures = './figures'
```
to point to the correct path to the `converted_data` saved in your machine. Create the figure directory if there isn't one.
3. Run through the cells in `Preoprocess_filter+artifact_removal.ipynb` (2 cells in total) The expected outputs are listed above. 
4. Note: The bad channels specified in `bad_channels.txt` are not removed by this programmatic pass. The channels in `bad_channels.txt` are identified based on the detected EOG figures. More refined method might be required to reject these channels manually along the time axis.

### Prepare feature matrix and labels
