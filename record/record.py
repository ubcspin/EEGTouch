import serial
import time

ser = serial.Serial('COM3', 9600)
time = str(int(time.time()))
outfile = open("recording_" + time + ".txt", 'w')
while True:
	data = ser.readline()
	outfile.write(str(data, 'utf-8'))
	print(data)
outfile.close()
