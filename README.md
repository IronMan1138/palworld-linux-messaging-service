# Palworld Automated Messaging Service
Messaging service for Palworld using ARRCON to send broadcast messages at whatever timeframe from an automated reboot time that you have established in a service file in your /etc/systemd/system/ directory

## ARRCON
Please see https://github.com/radj307/ARRCON for AARCON as it is needed for this service to run correctly.

## Contents

### palwprld-messaging.service
A service file to automate the running of the script.

### palworld-message-service.sh
A script that contains code to grab variables programatically so changes are only ever made in one place.
This script also containts the ARRCON commands to execute the broadcast of the messages alerting the user to an impending restart.
