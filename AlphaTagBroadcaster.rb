#!/usr/bin/env ruby
#
require "rubygems"
require "serialport"
require 'rest-client'
require 'base64'
require "awesome_print"

###-----------------USER CONFIGURATION-----------------###
port = "/dev/ttyACM0" #enter scanner USB/serial port in quotes here
baudrate = 115200 #enter scanner baudrate here
@icecastUser = "source" #enter icecast username in quotes here
@icecastPass = "***REMOVED***" #enter icecast password in quotes here
icecastServerAddress = "174.127.114.11:80" #enter icecast server IP Address (and port if necessary) here
icecastMountpoint = "***REMOVED***" #enter icecast mountpoint in quotes here - don't add leading '/'
@delay = 3 #enter the time in seconds of desired update delay time to match audio feed
@metadata = 'Searching for activity...' #default alpha tag for silence
###-----------------END USER CONFIGURATION---------------###

@urlBase = "http://" + icecastServerAddress + "/admin/metadata?mount=/" + icecastMountpoint + "&mode=updinfo&song="
# serTimeout = 0.005 # serial timeout here (.005 is probably sufficient)
@testString = "GLG" #'''test string to send to Uniden Scanner to get current status
#for BCT8 will be RF to get frequency, or LCD FRQ to read icon status
#for BC125AT use CIN'''
@tgidOld, @tgid = 0 #initialize TGID old test variable

@write_ser = SerialPort.new(port, baudrate)
@read_ser = SerialPort.new(port, baudrate)

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
  ap "updating alpha tag"
  ap alphaTag
  response = RestClient.get(url,
     {
         Authorization: "Basic #{Base64::encode64("#{@icecastUser}:#{@icecastPass}")}"
     }
  )
  if response.code == 200
    ap "Updated successfully at: #{DateTime.now.strftime("%A, %d %b %Y %l:%M:%S %p")}\n\n".to_s
  end
  # ap response.headers
  # ap response.body
end

postAlphaTag(@metadata)

while true
  pollData()
  sleep(0.1)
end
