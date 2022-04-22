#!/usr/bin/env ruby
#
require 'rubyserial'

serialport = Serial.new '/dev/ttyACM0' # Defaults to 9600 baud, 8 data bits, and no parity
serialport = Serial.new '/dev/ttyACM0', 57600
serialport = Serial.new '/dev/ttyACM0', 19200, 8, :even