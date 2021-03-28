# Visualization log
This document contains different kinds of visualization we've tried and the scripts we used to generate them

### June 29, 2020
Compare feeltrace slope breakdown by scenes and events. Two different methods of computing slopes don't have a significant impact on the resulting plot.
[Feeltrace slope box plot](visualizations/Event_x_joystick_value_slope.pdf) side by side with feeltrace value breakdown by events.
[Average slope plot](visualizations/Event_x_joystick_avg_slope.pdf) comparing 2 methods of computing slopes.
Generated with [`event_joystick.m`](experiments/event_joystick.m) in Tableau

### June 22, 2020
Normalized feeltrace to calibrated word range
[Box plot](visualizations/calibrated_words_interview_box_1.pdf) of aggregated feeltrace around (0.5s before 0.5s after) interview markers that mentioned calibrated words and their synonyms. The calibrated value of the words are shown in grey line.
[Same plot](visualizations/calibrated_words_interview_all.pdf) with all participants and averaged calibrated word values
Generated with [`interview_joystick.m`](experiments/interview_joystick.m)

### June 18, 2020
Clean up misaligned scenes and events for event x joystick and event x fsr
Updated [Event x joystick plot](visualizations/Event_x_joystick_all_par_sorted.pdf)

### June 17, 2020
Updates on fsr related plots
Now show scene in event x fsr plots. Scenes and events are sorted in chronological order.

[Box plot](visualizations/Event_x_fsr_box_sorted.pdf) of fsr streams around each event timestamp

[Filtered events with fsr data that are high intensity and low spread](visualizations/Event_x_fsr_box_sorted.pdf)

[Max fsr breakdown by key presses](visualizations/Event_x_fsr_maxfsr.pdf)

Generated with [`event_fsr.m`](experiments/event_fsr.m) in Tableau

### June 16, 2020
[Box plot](visualizations/Event_x_fsr_box_0.pdf) of fsr streams around each event timestamp for each participant. 
Generated with [`event_fsr.m`](experiments/event_fsr.m) in Tableau

[Box plot](visualizations/calibrated_words_interview_box_0.pdf) of feeltrace data around each interview markers that mentioned a calibrated word. The calibrated word value is plotted on top of each box. Filtered by participant. 
Generated with [`interview_joystick.m`](experiments/interview_joystick.m)
