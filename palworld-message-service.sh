#!/bin/bash

service="PalServer-Linux-Shipping"
uptime=0
timetostartmessages=15 #time in minutes

# palworldruntime grabs the value RuntimeMaxSec of the systemd file that runs palworld. palworldtimeframe grabs the letter designation e.g. h for hours
palworldruntime=$(sed -nE 's/^RuntimeMaxSec=([*0-9]+).*/\1/p' < ~/../../etc/systemd/system/palworld.service)
palworldtimeframe=$(sed -nE 's/^RuntimeMaxSec=[0-9]+([dh]).*/\1/p' < ~/../../etc/systemd/system/palworld.service)
palworldtimeframe=${palworldtimeframe//[0-9]/}

# countdowntime is now calculated based on if the systemd file is set for days our hours. It is also offset by timetostartmessages, so with timetostartmessages amount of time left, the messages will start.
if [[ "$palworldtimeframe" = "h" ]]; then
  countdowntime=$(((palworldruntime * 3600) - (timetostartmessages * 60 ))) # 3600 seconds in an hour
else
  countdowntime=$(((palworldruntime * 86400) - (timetostartmessage * 60))) # 86400 seconds in a day
fi

pid=$(pidof "$service")
newstart=true

# Next two lines programatically grab the admin password AND the port for RCON so if they ever change in the config file you don't have to change them in here as well.
password=$(sed -nE 's/.*AdminPassword="([^"]+)".*/\1/p' < ~/.steam/steam/steamapps/common/PalServer/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini)
rconport=$(sed -nE 's/.*RCONPort=([*0-9]+).*/\1/p' < ~/.steam/steam/steamapps/common/PalServer/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini)
while true;
do
  if [ "$newstart" = true ]; then
    newstart=false
    ./ARRCON -P "$rconport" -p "$password" "BroadCast This is a test of the Palworld Emergency Broadcast System (PEBS).  If this were an emergency, you would have been notified of imminent restart."
  elif [ "$uptime" -ge "$countdowntime" ]; then
    ./ARRCON -P "$rconport" -p "$password" "BroadCast I'm your aunt Debbie and your server will be restarting in 15 minutes"
    sleep 300
    ./ARRCON -P "$rconport" -p "$password" "BroadCast I'm Commander Shepard and this is my favorite Palworld server on the Citadel.  It will be restarting in 10 minutes"
    sleep 300
    ./ARRCON -P "$rconport" -p "$password" "BroadCast Ask me about my weiner! Also the server will be restarting in 5 minutes"
    sleep 240
    ./ARRCON -P "$rconport" -p "$password" "BroadCast He's dead Jim.  No he's not, he still has 1 minute before he restarts!"
    sleep 30
    ./ARRCON -P "$rconport" -p "$password" "BroadCast You see that movie 'Gone in 60 seconds'? Well this server is restarting in 30 seconds"
    sleep 15
    ./ARRCON -P "$rconport" -p "$password" "BroadCast You've got 15 seconds before this server reboots.  Better finish up that battle!"
    ./ARRCON -P "$rconport" -p "$password" "Save"

    # uptime is set back to 0 to start the loop from the beginning.
    # sleep for one minute to make sure the server is down before entering an until loop to wait for the service to come back up.
    # since the server will have rebooted, a new pid will have been assigned.
    # newstart is also reset so once the loop restarts it sends the intial message to show that the messaging service is online.
    uptime=0
    sleep 60

    {
    until systemctl status "palworld.service" | grep "Active: active (running)"
    do
      sleep 60 >/dev/null 2>&1
    done

    } >/dev/null 2>&1
    pid=$(pidof "$service")
    newstart=true
  else
    sleep 1 >/dev/null 2>&1
    uptime=$(ps -p "$pid" -o etimes=)
  fi
done
