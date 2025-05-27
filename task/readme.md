# Task Toolkit

## Installation
1. Connect to your MUOS device by usb-c cable or going to (your IP address):9090 (Port) (user:muos, pass:muos)
2. Copy files to mnt/mmc/MUOS/task/ (Home > SD1 (mmc) > MUOS > task)
3. On your device Application > Task Toolkit
4. Use scripts you copied 🎉

## HDMI On
HDMI is activated only when device boots and the cable is in, so I made a script that enables HDMI output in 1080p 60hz.
Use HDMI Off to return screen to rg34xx.

## Playtime
All your play time are save at
```
/mnt/mmc/muos/info/track/playtime_data.json
```
Script only shows that data, use A/B buttons to scroll between pages
To exit - R2+L2 (once exit screen will be scrambled press B button to exit completely)

## Migrate From SD1 to SD2 & vice versa
All your ROMs, Network settings, Screenshots, Save files, BIOS files will be transferred:
```
Source is from /mnt/mmc/ (SD1) 
Destination to /mnt/sdcard/ (SD2)
```
Credits goes to: https://github.com/MustardOS/internal/blob/8204f0b14d3ff93b7283339beb4293f79e246d08/init/MUOS/task/Migrate%20to%20SD2.sh
