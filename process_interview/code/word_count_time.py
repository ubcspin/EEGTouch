from nltk import word_tokenize
from nltk.probability import FreqDist

from utils import *
from plot import *

import glob
import csv
import operator
import os
from math import *



def parse_one_participant(path, out_path, participant_num):

	timeStamp_comment_map = {}

	with open(path,'rt', encoding = 'utf-16') as csvfile:
		interviewReader = csv.reader(csvfile, delimiter = '	')

		i = 0 
		print(participant_num)
		for row in interviewReader:
			if i == 0:
				i = 1 #skip first line
			else:
				timeStamp_comment_map[row[2]] = FreqDist(word.lower() for word in tokenize(row[0], check_negation=False, time_stamp=row[2]))


	timeStamps = []
	scales = []

	notRecognizedtimeStamps = []
	notRecognizedScales = []

	with open(out_path, 'w', newline='') as outputfile:	
		writer = csv.writer(outputfile)
		writer.writerow(["time","recognized emotion","word calibrated", "Emotion level"])
		for time, dist in timeStamp_comment_map.items():
			emotions = getEmotion(dist)
			
			try:
				scale_one_line = toScale(emotions, participant_num)
				scales += scale_one_line
				timeStamps.append(time)
				
				for i in range(len(emotions)):
					if scale_one_line[i] != None:
						writer.writerow([time, emotions[i][0], emotions[i][1], scale_one_line[i]])
					else:
						writer.writerow([time, emotions[i][0], emotions[i][1], ''])
			except NoEmotionRecognizedException:
				notRecognizedtimeStamps.append(time)
				notRecognizedScales.append(0)
				writer.writerow([time, emotions[0][0], emotions[0][1], ''])


	# Uncomment to plot calibrated words agains time
	# Commented out since plotting is moved to matlab
	# plot_participant(timeStamps, scales, notRecognizedtimeStamps, notRecognizedScales, participant_num)




########################################################################################
# main

# the directory that contains all the interview csv files
data_path = "../data"
# the directory to store all the processed data
out_path = "../processed"

try:  
    os.mkdir(out_path)
except OSError:  
    print ("Creation of the directory %s failed or the directory already exists" % out_path)
else:  
    print ("Successfully created the directory %s " % out_path)

for i in range(1,24):
	parse_one_participant(os.path.join(data_path, 'interview-'+str(i)+'.csv'), os.path.join(out_path, 'try-'+str(i)+'.csv'), i)


