#!/usr/bin/env ruby
#
require 'serialport'


###-----------------USER CONFIGURATION-----------------###
port = "/dev/ttyACM0" #enter scanner USB/serial port in quotes here
baudrate = 115200 #enter scanner baudrate here
icecastUser = "source" #enter icecast username in quotes here
icecastPass = "***REMOVED***" #enter icecast password in quotes here
icecastServerAddress = "174.127.114.11:80" #enter icecast server IP Address (and port if necessary) here
icecastMountpoint = "***REMOVED***" #enter icecast mountpoint in quotes here - don't add leading '/'
delay = 0 #enter the time in seconds of desired update delay time to match audio feed
###-----------------END USER CONFIGURATION---------------###


ser = SerialPort.new(port, baudrate, 8, 1, SerialPort::NONE)
ser.write('GLG\r\n')
response = ser.readline("\r")
response.chomp!
ap "#{response}\n"