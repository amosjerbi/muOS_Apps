#!/bin/sh
# HELP: HDMI On
# ICON: ethernet

# Source the common functions
. /opt/muos/script/var/func.sh

# Check current HDMI state
check_hdmi_state() {
    if [ -f "/tmp/hdmi_in_use" ]; then
        cat "/tmp/hdmi_in_use"
    else
        echo "0"
    fi
}

# Toggle HDMI state
toggle_hdmi() {
    current_state=$(check_hdmi_state)
    if [ "$current_state" = "0" ]; then
        # Turn HDMI on
        DISPLAY_WRITE disp0 switch1 "4 10 0 0 0x4 0x000 0 1 0 8" # Using 1080p (1920x1080) - Enhanced (No Overscan, Full Range)
        HDMI_SWITCH
        REFRESH_HDMI 1
        
        # Set framebuffer for external display
        [ "$(GET_VAR "global" "settings/hdmi/enabled")" -eq 1 ] && SCREEN_TYPE="external" || SCREEN_TYPE="internal"
        FB_SWITCH "$(GET_VAR "device" "screen/$SCREEN_TYPE/width")" "$(GET_VAR "device" "screen/$SCREEN_TYPE/height")" 32
        echo "HDMI activated"
    else
        # Turn HDMI off
        DISPLAY_WRITE disp0 switch1 "4 0 0 0 0x4 0x201 0 0 0 8"
        HDMI_SWITCH
        REFRESH_HDMI 0
        echo "HDMI deactivated"
    fi
}

# Execute toggle
toggle_hdmi