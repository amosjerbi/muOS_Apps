#!/bin/sh
# HELP: HDMI Off
# ICON: ethernet

# Source MustardOS functions
. /opt/muos/script/var/func.sh

# Disable HDMI first
DISPLAY_WRITE disp0 switch1 "0 0 0 0 0x4 0x201 0 0 0 8"
sleep 1

# Enable LCD interface
DISPLAY_WRITE lcd0 enable 1
sleep 1

# Set LCD as primary display with 480x320
DISPLAY_WRITE disp0 switch0 "1 480 320 60 0x4 0x201 0 0 0 8"
sleep 1

# Enable display
DISPLAY_WRITE disp0 enable 1

# Set framebuffer to 480x320
/opt/muos/extra/mufbset -w 480 -h 320 -d 32

# Update state
echo "0" > /tmp/hdmi_in_use

# Force refresh
echo 1 > /tmp/hdmi_do_refresh

echo "LCD enabled at 480x320"
echo "LCD interface enabled as primary display"

# Additional screen switching logic
[ "$(GET_VAR "global" "settings/hdmi/enabled")" -eq 1 ] && SCREEN_TYPE="external" || SCREEN_TYPE="internal"
FB_SWITCH "$(GET_VAR "device" "screen/$SCREEN_TYPE/width")" "$(GET_VAR "device" "screen/$SCREEN_TYPE/height")" 32
