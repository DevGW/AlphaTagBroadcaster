# AlphaTagBroadcaster

## Ruby script to get alpha tags from Uniden scanners<br>For Broadcastify feeds<br>Tested on Ruby 2.7.4, 3.0.1+ 
### Install ruby development libraries
```sudo apt-get install ruby-dev```

### Install gems
```bundle install```

## Configure your settings
```ruby
###-----------------USER CONFIGURATION-----------------###
port = "/dev/ttyACM0" #enter scanner USB/serial port in quotes here
baudrate = 115200 #enter scanner baudrate here
@icecastUser = "source" #enter icecast username in quotes here
@icecastPass = "asdf1234" #enter icecast password in quotes here
icecastServerAddress = "174.127.114.11:80" #enter icecast server IP Address (and port if necessary) here
icecastMountpoint = "asdf1234abcd" #enter icecast mountpoint in quotes here - don't add leading '/'
@delay = 3 #enter the time in seconds of desired update delay time to match audio feed
@metadata = 'Searching for activity...' #default alpha tag for silence
###-----------------END USER CONFIGURATION---------------###
```
## Run from command line
```bash
./AlphaTagBroadcaster.rb
```
## Run at startup as a service / systemd
```shell
sudo systemctl edit --force --full AlphaTagBroadcast.service
```
### Paste the following
```shell
[Unit]
Description=Alpha Tag Broadcast Service
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=/home/pi
ExecStart=/home/pi/path_to_AlphaTagBroadcaster.rb
Restart=always
StandardOutput=file:/var/log/AlphaTagBroadcast.log
StandardError=inherit

[Install]
WantedBy=multi-user.target
```
### Enable the service
```bash
sudo systemctl enable AlphaTagBroadcast.service
```
### Start the service
```bash
sudo systemctl start AlphaTagBroadcast.service
```
