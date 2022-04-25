#!/usr/bin/env ruby
# v1.0
require "rubygems"
require "serialport"
require 'rest-client'
require 'base64'
require "awesome_print"

###-----------------USER CONFIGURATION-----------------###
port = "/dev/ttyACM0" #enter scanner USB/serial port in quotes here
baudrate = 115200 #enter scanner baudrate here
@icecastUser = "source" #enter icecast username in quotes here
@icecastPass = "asdf1234" #enter icecast password in quotes here
icecastServerAddress = "174.127.114.11:80" #enter icecast server IP Address (and port if necessary) here
icecastMountpoint = "asdf1234abcd" #enter icecast mountpoint in quotes here - don't add leading '/'
@delay = 1 #enter the time in seconds of desired update delay time to match audio feed
@metadata = 'Searching for activity...' #default alpha tag for silence
@enableLogging = true #turn on or off logging output
@logToFile = true #if @enableLogging is true, this will log to @logFilePath below, false logs to stdout
@logFilePath = "/home/pi/AlphaTagBroadcaster/logfile" # full absolute path to logfile. Ensure directory exists and has correct permissions
###-----------------END USER CONFIGURATION---------------###

@urlBase = "http://" + icecastServerAddress + "/admin/metadata?mount=/" + icecastMountpoint + "&mode=updinfo&song="
serTimeout = 5 # serial timeout here (5 milliseconds is probably sufficient)
@testString = "GLG" #'''test string to send to Uniden Scanner to get current status
#for BCT8 will be RF to get frequency, or LCD FRQ to read icon status
#for BC125AT use CIN'''
@tgidOld, @tgid = 0 #initialize TGID old test variable

begin
  @write_ser = SerialPort.new(port, baudrate)
  @read_ser = SerialPort.new(port, baudrate)
  @read_ser.read_timeout = serTimeout
rescue Exception => e
  ap e.message
  ap e.backtrace.inspectrescue
  ap "rescuing"
  sleep 10
  retry
end

def pollData
  @write_ser.write("#{@testString}\r")
  data = @read_ser.readlines()
  # ap "#{data}"
  parseData(data)
end

def parseData(data)
  if data.is_a?(Array) && data.count > 0
    begin
      parsedData = data[0].chomp!.split(",", -1)
      # ap "parsing"
      # ap parsedData
      testChars = parsedData[0]
      if testChars == @testString
        # ap "test passed"
        if parsedData.count >= 10
          # ap "parsedData count passed"
          if !parsedData[1].to_s.strip.empty?
            # ap "parsedData[1] not blank"
            @tgid = parsedData[1]
            if @tgid != @tgidOld
              # ap "@tgid != @tgidOld"
              sys = parsedData[5]
              group = parsedData[6]
              talkGroup = parsedData[7]
              @metadata = "#{sys} - #{group} (#{talkGroup})"
              Thread.new { postAlphaTag(@metadata) }
            end
          elsif @metadata != 'Searching for activity...'
            # ap "metadata does not match"
            @metadata = 'Searching for activity...'
            Thread.new { postAlphaTag(@metadata) }
          end
        end
      end
    rescue Exception => e
      ap e.message
      ap e.backtrace.inspect
    end
  end
end

def postAlphaTag(alphaTag)
  formattedAlphaTag = alphaTag.gsub(" ", "+")
  @tgidOld = @tgid
  url = "#{@urlBase}#{formattedAlphaTag}"
  sleep @delay
  response = RestClient.get(url,
     {
         Authorization: "Basic #{Base64::encode64("#{@icecastUser}:#{@icecastPass}")}"
     }
  )
  appendLog(alphaTag, response.code)

  # if response.code == 200
  # else
  # end
  # ap response.headers
  # ap response.body
end

@logStr = <<EOLS
  ######################################################################
  ### updating alpha tag
  ### #{alphaTag}
  ### Updated successfully at: #{DateTime.now.strftime("%A, %d %b %Y %l:%M:%S %p")}
  ######################################################################

EOLS

def appendLog(alphaTag, responseCode)
  if @enableLogging && responseCode == 200
    ap @logStr
  elsif @enableLogging
    ap "### Update failed with code: #{response.code}"
  end
end

postAlphaTag(@metadata)

while true
  pollData()
  sleep(0.1)
end
