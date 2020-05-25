
## Data Pre-Processing Scripts:

These are used with matlab to pre-process raw data from the EEG study.
To use:

1) Ensure Matlab is installed. Information on free licensing of Matlab for UBC: https://it.ubc.ca/services/desktop-print-services/software-licensing/matlab

2) Navigate to the ubc/cs/research/imager/project/spin/proj/eeg/ directory on the UBC CS server. 
Download the following data from one trial to a directory on your computer:
-Gameplay CSV (usually gameplay*.csv)
-Feeltrace CSV (usually feeltrace*.csv)
-Gameplay video (usually gameplay*.mov)
-EEG data in Matlab format (saved with datestamp, the only *.mat file in the directory)
-The entire subdirectory ending in .mff

3) For best results, download VLC video player and ensure the VLC keyword is on your path. 
Currently only supported for Windows and Mac.

4) Clone this repository and open the /matlab/ directory within it in Matlab.

5) Type "process_data" in the Matlab command line and press enter

6) Follow the prompts 

7) Your data shoud process!

When processing the video, please note that Matlab will attempt to automatically open VLC. This only works if VLC is on your path. If the videos do not automatically open when Matlab gives a "Attempting to play video..." prompt, please locate the file referred to in the prompt manually.

The processed video, and the other processed data, is saved by default to a /#_processed_data/ subdirectory inside the raw data directory. If an error was encountered writing to this location, the script prompts for an alternate location. 

Please note that importing the FSR and Feeltrace data is a slow process. The progress bar on the pop-up may appear static while this process is taking place, but this does not mean the application has hung up. If you want to check the progress as the scripts run, press "Pause" in Matlab.

***

Options

***

This script does not align video of the participant's face by default. Video of the participant's face can be aligned if the "%" is removed from the "%video_face_align" line in process_data.m. Please note, processing and aligning video data is extremely time consuming, much more so than processsing and aligning Feeltrace and FSR data.

***

What do you get?

***

After data processing has completed, the /#_processed_data/ directory will contain:

-A Matlab file containing the struct "aligned_data" containing aligned data from EEG, FSRs, and Feeltrace. (And video, if video option is enabled), and another struct "scalars" containing important scalar values like sync indices.

-A PNG image of raw EEG data

-A PNG image of Feeltrace data and keypresses

-A processed video excerpt containing the sync frame

This processed data directory can then be uploaded to the server into the processed data p directory.

***

How do I know which DIN?

***

If multiple DINS were recorded in the EEG data, you need to select which one to use as the sync signal.
If you are unsure which DIN is correct, check the "Participant trial overview" spreadsheet on the EEG Coord Google Drive.

***

What's up with the video?

***

This script has you find the sync frame of the video manually. First, watch the video carefully and ensure you've seen all times the sync button is pressed before gameplay begins. Determine which of the presses is the "relevant" sync.

What's the relevant sync?

If there is only one DIN signal in the EEG data, choose the sync that would correspond with this DIN. For example, if there is one sync button press before the EEG is recording and one after the EEG is recording, then the seond sync button press is the relevant sync and you should enter 2 in the "which sync" where you also enter the video start time and duration.

Note that sync button presses are indexed from the FINAL time the Node server is started before gameplay begins. So if someone opened the server, pressed sync, closed the server, re-opened it, and then pressed sync again just once, enter "1" for which sync.

If there were multiple DINs in the EEG data, make sure to enter the sync number (with 1 = the first sync button press) that corresponds with the DIN that was selected in the which DIN dialog.

Then, note a start time and second duration that will contain the frame for the sync button press you have entered as the relevant sync.
Matlab will then process the video with frame numbers so that you can get the precise frame number for the sync.
  
-


## tableau

scripts created to prepare csv for tableau

***

Before you start

***
- Add `processed_data_pxx` to path (right click Add to Path, selected folders and subfolders, icon solidifies to indicate added to path)
- Directory structure (for folders related to tableau)
```
-- matlab
	 |-- tableau
	 | 		|-- xxx.m
	 | 		|-- xxx.csv
	 |-- experiments
	 		|-- xxx.m
	 	  	|-- results
     				|-- xxx.csv
```
***

Event x joystick analysis

***

`matlab/experiments/event_joystick.m`

1. Extracting joystick data
	- For every event of each participant, extract joystick data around the event timestamp
	- Compare four time windows (250ms, 500ms, 750ms, 1000ms before and 5000ms after the event timestamp)
	- abs: max value of joystick data in time window
	- variance: variance of joystick data in time window
	- slp: end - start / time in a time window
	- slp2: average of slopes of every 2 adjacent points in time window
	- Output saved in `event_joystick_asym.csv`
2. Spread in time window
	- Calculate spread of joystick data for events that have been experienced by at least 16 participants
	- Record abs, var, slp for each of four time windows
	- Output saved in `ej_spread_5500_9500.csv`
3. Normality testing
	- [Shapiro-Wilk test](https://www.mathworks.com/matlabcentral/mlc-downloads/downloads/submissions/13964/versions/2/previews/swtest.m/index.html) at alpha = 0.05. It has the best power for a given significance compared to other normality tests.
	- Perform normality testing on value (`abs`) and variance (`var`) with time window 1s before and 5s after
	- Output saved in `event_x_joystick.csv`
	- Intepretation:
		- "h-abs/h-var" refers to the results of the normality hypothesis testing - 0 means the null hypothesis is NOT rejected and p>0.05, and hence the distribution is NORMAL. "p-abs/p-var" are p-values.
		- "kurt-abs/kurt-var" is kurtosis - kurt > 3 means the distribution is more outlier-prone than standard normal distribution (aka the distribution is heavier tailed than standard normal) and vice versa.
		- "skew-abs/skew-var" is skewness of the distribution - negative means skewed to the left, positive means skewed to the right
		- "spread-abs/spread-var" is based on the results of the normality testing


