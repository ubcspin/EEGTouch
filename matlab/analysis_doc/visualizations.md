# Visualization log
This document contains different kinds of visualization we've tried and the scripts we used to generate them

### June 17, 2020
Updates on fsr related plots
Now show scene in event x fsr plots. Scenes and events are sorted in chronological order.
[Box plot](visualizations/Event_x_fsr_box_sorted.pdf) of fsr streams around each event timestamp
[Filtered events with fsr data that are high intensity and low spread](visualizations/Event_x_fsr_box_sorted.pdf)
[Max fsr breakdown by key presses](visualizations/Event_x_fsr_maxfsr.pdf)


### June 16, 2020
[Box plot](visualizations/Event_x_fsr_box_0.pdf) of fsr streams around each event timestamp for each participant. 
Generated with [`event_fsr.m`](experiments/event_fsr.m) in Tableau

[Box plot](visualizations/calibrated_words_interview_box_0.pdf) of feeltrace data around each interview markers that mentioned a calibrated word. The calibrated word value is plotted on top of each box. Filtered by participant. 
Generated with [`interview_joystick.m`](experiments/interview_joystick.m)
