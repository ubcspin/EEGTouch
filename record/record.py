import serial
import time

ser = serial.Serial('/dev/tty.usbserial', 9600)
time = str(int(time.time()))
outfile = open("recording_" + time + ".txt")
while True:
	data = ser.readline()
	outfile.println(data)
	print(data)