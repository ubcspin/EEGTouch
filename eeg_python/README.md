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
- install python version 3.9.2
https://www.python.org/downloads/
- install miniconda version 4.9.2 (uses python version 3.8.5)
https://docs.conda.io/en/latest/miniconda.html
- ***move filtered-eeg folder; converted_data from server to C:\Users\Documents\Github (same level as EEGTouch)
filter(converted_data) -> filtered-eeg
ubc/cs/research/imager/project/spin/proj/eeg
- clone ubcspin\EEGTouch repository and change to ongoing-analysis branch
https://github.com/ubcspin/EEGTouch/tree/ongoing-analysis/eeg_python
pull / fetch to ensure updated code
- open conda shell (start menu -> Anaconda3(64-bit) -> Anaconda Powershell Prompt (Miniconda3)
	- in the shell: 
	- navigate to ..\GitHub\EEGTouch\eeg_python 
	- command: conda env create -n <give-a-name-to-the-env> -f environment.yml
		- note: you used 'qian' as the environment name
- activate conda
	activate <environment name> ("qian" in example)
- open jupyter
	jupyter notebook
	-> Preoprocess_filter+artifact_removal [identifies and removes EOG events via ICA]
		-> run
		-> Ctrl-C in terminal to quit run
		-> .png saved in C:\Users\SPIN-admin\Documents\GitHub\EEGTouch\eeg_python\figures\eog

	-> Preprocess_feature_extraction [calculates features and labels; writes to npy and csv]
		-> feature file: data_features.npy; data_label.npy is feeltrace-slope values (not yet binned-rename to data_slope.npy?) and data_state.npy is feeltrace-value (not yet binned) saved in C:\Users\SPIN-admin\Documents\GitHub\EEGTouch\eeg_python\data\processed_features_and_labels\2
		-> current version samples feeltrace every second; fine for end-start/t for slope calculation but if we wanted finer slope-vals, will need to change linear interpolation process [In setting feeltrace block]
			*new_timestamp = np.arange(p2_feeltrace[0,0], p2_feeltrace[-1,0], 1000)
			p2_feeltrace_even = np.interp(new_timestamp, p2_feeltrace[:,0], p2_feeltrace[:,1])
			
		[In reshaping block]: 
			sets 2D array to 3D array [num_seconds X 1000 samples X 64 channels] (1s data instances has 1000 samples per channel)
			
		[In channels]: setting channels for band features, gamma, beta, first difference
		
		[In main feature calc block]:
			*bicoherence calc ln 131 denom may have multiple implementations; this is just one - consider testing another. ref linked at ln 112 (img linked also acts as ref) 
			*another ref: https://github.com/synergetics/spectrum
			
			hjorth (pkg calcs)
			
			fractal dim (pkg calcs)
		
			HOC - higher order crossing (based on pkg on zero-crossing)
			
		[In feature construction block]
			apply all calcs and outputting as [feature_name, result]
			
		runs per participant (P2 and P5 have been run -> similar results)
	
	-> EEG_benchmark [build model for classification and regression]
		-> todo: *have not run leave one participant out on label sets
		-> todo: *have run 2-s fsr instances around game events only - is NOT comparable to EEG classification here which is 1-s consecutive windows along entire gameplay
		-> Load data: load feature set; load label set
		-> Inspect if there are colinearities: identified highly correlated features, removed one
		-> Separate training and testing set: extract dog scene to use as test set (scene.csv file may have scene timestamps)
			-> build test / train sets
			TODO: try *random* test/train sets rather than middle scene
				- lesser: only before scene rather than before and after
		-> LGBM: boosted tree regression hyperparameters set [small, med, large]
			-> picks tree with highest CV score
		-> Lasso: lasso cv (5 fold default)
		-> Slope classification with multiple models: load slope data and process into 3 bins: [-1, 0, 1]
			viz of class distribution
			todo: note class imbalance - models that can handle imbalance OR balance classes
			- these models assume iid; may need to look at models that are designed to predict from timeseries 
			- anecdote: Schmidt was working on EEG data from kinesiology using EEG to predict neuroabnormalities (seizure? concussion?) but splitting data into consecutive time windows and treated as independent samples for classification was not effective ** exactly us **
		
		-> Visualize feature and label space with tSNE: decomposition using tSNE to n-comp = 2 (down to 2 dimensions)
			-> squeeze from matrix to vector
			-> visualize decomposition *note blob of things - classes are entangled
			-> test and train set to bin labels (was slope val before for reg)
			
		-> Feature selection with RFECV):
			-> removes lowest performing features (bottom 50% bc step=0.5) based on CV (RF assigns importance to features) 
			-> note result in [57], all 93 features assigned a rank of 1 
			-> in [58] support_ shows TRUE for all therefore, keep all is recommended
			
		-> Classification with RF
			-> combinations of param_grid vals = 18 candidates
			-> check best fit - output: gini - 10 - 10
			-> prediction only 0 <-
			
		-> Classification with logistic regression
			-> Out[65]: array([ [  9,  41,  12],
								[ 53, 172,  38],
								[ 10,  43,  15]]) is CV training results
			-> dog scene test gets ~50%
		
		-> Classification with KNN
			-> similar output to log reg
			
		-> Inspecting distances between training examples
			-> compare distance between each pair of data instances
			-> histogram x-axis distance vals; y-axis freq
			
		-> Classification with support vector machine
			-> predict 0 (acts more like RF)
			-> note out[89]: param_C is inverse of L2-reg val so in row 6, very low reg or high param_C shows high train-score (model working evidence)
			
		-> Classification with simple neural network
			-> predicts 0 
			
		*** end of classification on emotion traj slope bins	
		
		-> Regression on emotion state (feeltrace value)
			-> StandardScaler() transforms labels into z-score to 10 bins (specify bin vals)
			-> best one is negative using R-squared 0_o
			
		-> Classification on emotion state
			-> out plt.hist(y): distribution of feeltrace val
			-> out plt.bar...: binned based on 1/3 of vals
			-> use SVM, predicts -1
			
			
			
			
		
		
