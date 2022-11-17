#!/usr/bin/env ruby
# v1.0
require "rubygems"
require "serialport"
require 'rest-client'
require 'base64'
require "awesome_print"
require 'curses'

###-----------------USER CONFIGURATION-----------------###
port = "/dev/ttyACM0" #enter scanner USB/serial port in quotes here
baudrate = 115200 #enter scanner baudrate here
@delay = 1 #enter the time in seconds of desired update delay time to match audio feed
@metadata = 'Searching for activity...' #default alpha tag for silence
###-----------------END USER CONFIGURATION---------------###

serTimeout = 5 # serial timeout here (5 milliseconds is probably sufficient)
@testString = "STS" #'''test string to send to Uniden Scanner to get current status
#for BCT8 will be RF to get frequency, or LCD FRQ to read icon status
#for BC125AT use CIN'''
@tgidOld, @tgid = 0 #initialize TGID old test variable

@write_ser = SerialPort.new(port, baudrate)
@read_ser = SerialPort.new(port, baudrate)
@read_ser.read_timeout = serTimeout

Curses.init_screen
Curses.start_color
Curses.init_pair(1, Curses::COLOR_WHITE, Curses::COLOR_BLUE)
@win = Curses::Window.new(0, 0, 1, 2)


def screen_update(data)
  begin
    #  win = Curses.stdscr
    x = @win.maxx / 2
    y = @win.maxy / 2
    #    x = Curses.cols / 2  # We will center our text
    #    y = Curses.lines / 2
    @win.setpos(y, x)  # Move the cursor to the center of the screen
    @win.bkgd(Curses.color_pair(1))
    @win.addstr("#{data[6]}")  # Display the text
    @win.setpos(y+1, x)  # Move the cursor to the center of the screen
    @win.addstr("#{data[8].split('(').first}")  # Display the text
    @win.setpos(y+2, x)  # Move the cursor to the center of the screen
    @win.addstr("#{data[10]}")  # Display the text
    @win.setpos(y+3, x)  # Move the cursor to the center of the screen
    @win.addstr("#{data[12]}")  # Display the text
    @win.refresh  # Refresh the screen
    #    Curses.getch  # Waiting for a pressed key to exit
  ensure
    #    Curses.close_screen
  end
end

def pollData
  @write_ser.write("#{@testString}\r")
  data = @read_ser.readlines()
  #    ap "#{data[0].gsub!('\u0006\a','') if !data[0].nil?}"
  if data.is_a?(Array) && data.count > 0
    begin
      parsedData = data[0].scrub("*").chomp!.split(",", -1)
      #     ap parsedData
      screen_update(parsedData)
      # else
      #   ap "something not right"
      #   ap data
    rescue
      #### move along nothing to see
    end
  end
  # parseData(data)
end

def main_loop
  while true
    pollData()
    sleep(0.1)
  end
end

# main_pid = fork do
main_loop
# end

# puts "running forked process as pid #{main_pid}"
