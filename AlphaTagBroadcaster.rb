#!/usr/bin/env ruby
#
require "rubygems"
require "serialport"
require "awesome_print"

###-----------------USER CONFIGURATION-----------------###
port = "/dev/ttyACM0" #enter scanner USB/serial port in quotes here
baudrate = 115200 #enter scanner baudrate here
icecastUser = "source" #enter icecast username in quotes here
icecastPass = "***REMOVED***" #enter icecast password in quotes here
icecastServerAddress = "174.127.114.11:80" #enter icecast server IP Address (and port if necessary) here
icecastMountpoint = "***REMOVED***" #enter icecast mountpoint in quotes here - don't add leading '/'
delay = 0 #enter the time in seconds of desired update delay time to match audio feed
###-----------------END USER CONFIGURATION---------------###

@urlBase = "http://" + icecastServerAddress + "/admin/metadata?mount=/" + icecastMountpoint + "&mode=updinfo&song="
# serTimeout = 0.005 # serial timeout here (.005 is probably sufficient)
@testString = "GLG" #'''test string to send to Uniden Scanner to get current status
#for BCT8 will be RF to get frequency, or LCD FRQ to read icon status
#for BC125AT use CIN'''
@TGIDold, @TGID = 0 #initialize TGID old test variable
@metadata = 'Searching for activity...'

@write_ser = SerialPort.new(port, baudrate)
@read_ser = SerialPort.new(port, baudrate)

def pollData
  @write_ser.write("#{@testString}\r")
  response = @read_ser.readline("\r")
  ap "#{response}\n"
  sleep(0.1)
end

while true
  pollData
end
