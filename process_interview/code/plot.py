from utils import *
import matplotlib.pyplot as plt


def plot_participant(x,y,x_not,y_not, participant_num):

	fig = plt.figure(figsize=[40,10])
	plt.ylim(-10,10)
	plt.plot(x,y)
	plt.scatter(x,y)
	plt.scatter(x_not,y_not, c='r')

	plt.xlabel('time(s)')
	plt.ylabel('emotional scale')
	plt.savefig('../fig/try-'+ str(participant_num) +'.pdf')
	plt.close()
