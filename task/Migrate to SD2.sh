#!/bin/sh
# HELP: Migrate to SD2
# ICON: sdcard

#---------------------------------------------------------#
# This script is designed to migrate selected user data
# from SD1 to SD2:
# - ROMs
# - Network settings
# - Screenshots
# - Save files
# - Scrappy data
#---------------------------------------------------------#

# Check if using e Pre-Banana version of muOS
MUOS_VER=$(head -n 1 /opt/muos/config/version.txt | awk '{print $1}' | cut -d'_' -f1)
if [ $(echo "$MUOS_VER < 2405.3" | bc) -eq 1 ]; then
	CURRENT_VER="PREBANANA"
else
	CURRENT_VER="BANANA"
fi

# Fire up the logger (Pre-Banana)
if [ $CURRENT_VER = "PREBANANA" ]; then
	/opt/muos/extra/muxlog &
	sleep 1

	TMP_FILE=/tmp/muxlog_global
	rm -rf "$TMP_FILE"
fi

# Define source locations
SD1_ROM="/mnt/mmc/ROMS"
SD1_NETWORK="/mnt/mmc/MUOS/network"
SD1_SCREENSHOT="/mnt/mmc/MUOS/screenshot"
SD1_SAVE="/mnt/mmc/MUOS/save"
SD1_SCRAPPY="/mnt/mmc/MUOS/application/Scrappy/.scrappy/data"

# Define target locations
SD2_ROM="/mnt/sdcard/ROMS"
SD2_NETWORK="/mnt/sdcard/MUOS/network"
SD2_SCREENSHOT="/mnt/sdcard/MUOS/screenshot"
SD2_SAVE="/mnt/sdcard/MUOS/save"
SD2_SCRAPPY="/mnt/sdcard/MUOS/application/Scrappy/.scrappy/data"

# See if SD2 is mounted.
# Let's do this early in case it's not here.
if grep -m 1 "mmcblk1" /proc/partitions >/dev/null; then
	echo "SD Card 2 has been detected."
	echo -e "Continuing.\n"
	if [ $CURRENT_VER = "PREBANANA" ]; then
		echo "SD Card 2 has been detected." >/tmp/muxlog_info
		echo -e "Continuing.\n" >/tmp/muxlog_info
	fi
else
	echo "SD Card 2 not detected."
	echo -e "Aborting!\n"
	if [ $CURRENT_VER = "PREBANANA" ]; then
		echo "SD Card 2 not detected." >/tmp/muxlog_info
		echo -e "Aborting!\n" >/tmp/muxlog_info
	fi
	sleep 10
	exit 1
fi

# Create temporary directory
MUX_TEMP="/opt/muxtmp"
mkdir -p "$MUX_TEMP"

RSYNCLOG="/mnt/sdcard/migrate_log.txt"

# Initialize total size
TOTAL_SIZE=0

# Get the size of a directory in MB
GET_SIZE() {
	if [ -d "$1" ]; then
		du -sm "$1" | awk '{print $1}'
	else
		echo "0"
	fi
}

# Calculate sizes
if [ -d "$SD1_ROM" ]; then
	ROM_SIZE=$(GET_SIZE "$SD1_ROM")
	TOTAL_SIZE=$((TOTAL_SIZE + ROM_SIZE))
	echo "Size of ROM Folder: $ROM_SIZE MB"
fi

if [ -d "$SD1_NETWORK" ]; then
	NETWORK_SIZE=$(GET_SIZE "$SD1_NETWORK")
	TOTAL_SIZE=$((TOTAL_SIZE + NETWORK_SIZE))
	echo "Size of Network Folder: $NETWORK_SIZE MB"
fi

if [ -d "$SD1_SCREENSHOT" ]; then
	SCREENSHOT_SIZE=$(GET_SIZE "$SD1_SCREENSHOT")
	TOTAL_SIZE=$((TOTAL_SIZE + SCREENSHOT_SIZE))
	echo "Size of Screenshot Folder: $SCREENSHOT_SIZE MB"
fi

if [ -d "$SD1_SAVE" ]; then
	SAVE_SIZE=$(GET_SIZE "$SD1_SAVE")
	TOTAL_SIZE=$((TOTAL_SIZE + SAVE_SIZE))
	echo "Size of Save Folder: $SAVE_SIZE MB"
fi

if [ -d "$SD1_SCRAPPY" ]; then
	SCRAPPY_SIZE=$(GET_SIZE "$SD1_SCRAPPY")
	TOTAL_SIZE=$((TOTAL_SIZE + SCRAPPY_SIZE))
	echo "Size of Scrappy Folder: $SCRAPPY_SIZE MB"
fi

# Print the total size
echo -e "\nTotal size of folders to migrate: ${TOTAL_SIZE} MB"

# Check free space
SD_FREE_SPACE=$(df -m /mnt/sdcard | awk 'NR==2 {print $4}')
echo -e "Total free space on SD Card 2: ${SD_FREE_SPACE} MB\n"

# Check if there is enough space before continuing
if [ $TOTAL_SIZE -lt $SD_FREE_SPACE ]; then
	echo -e "\nThere is enough free space for the migration."
	echo -e "Continuing.\n"
else
	echo -e "\nThere is not enough free space for the migration!"
	echo "Aborting!"
	sleep 10
	exit 1
fi

# Generate Exclusion List
cat <<EOF > $MUX_TEMP/sync_exclude.txt
.stfolder/
EOF

# Use --remove-source-files to move instead of copy
RSYNC_OPTS="--verbose --archive --checksum --remove-source-files --exclude-from=$MUX_TEMP/sync_exclude.txt --log-file=$RSYNCLOG"

# Create necessary directories
echo "Creating necessary directories on SD2..."
mkdir -p "$SD2_ROM" "$SD2_NETWORK" "$SD2_SCREENSHOT" "$SD2_SAVE" "$SD2_SCRAPPY"
chmod 777 "$SD2_ROM" "$SD2_NETWORK" "$SD2_SCREENSHOT" "$SD2_SAVE" "$SD2_SCRAPPY"

# Move ROMs
if [ -d "$SD1_ROM" ]; then
	echo -e "\nMoving ROMs to SD Card 2"
	rsync $RSYNC_OPTS "${SD1_ROM}/" "${SD2_ROM}/"
	find "$SD1_ROM" -type d -empty -delete
fi

# Move Network settings
if [ -d "$SD1_NETWORK" ]; then
	echo -e "\nMoving Network settings to SD Card 2"
	rsync $RSYNC_OPTS "${SD1_NETWORK}/" "${SD2_NETWORK}/"
	find "$SD1_NETWORK" -type d -empty -delete
fi

# Move Screenshots
if [ -d "$SD1_SCREENSHOT" ]; then
	echo -e "\nMoving Screenshots to SD Card 2"
	rsync $RSYNC_OPTS "${SD1_SCREENSHOT}/" "${SD2_SCREENSHOT}/"
	find "$SD1_SCREENSHOT" -type d -empty -delete
fi

# Move Saves
if [ -d "$SD1_SAVE" ]; then
	echo -e "\nMoving Saves to SD Card 2"
	rsync $RSYNC_OPTS "${SD1_SAVE}/" "${SD2_SAVE}/"
	find "$SD1_SAVE" -type d -empty -delete
fi

# Move SCRAPPY 
if [ -d "$SD1_SCRAPPY" ]; then
	echo -e "\nMoving SCRAPPY files to SD Card 2"
	rsync $RSYNC_OPTS "${SD1_SCRAPPY}/" "${SD2_SCRAPPY}/"
	find "$SD1_SCRAPPY" -type d -empty -delete
fi

# Sync Filesystem
echo -e "\nSyncing Filesystem"
sync

# Clean Up
rm -rf "$MUX_TEMP"

echo -e "\nMigration completed! Files have been moved from SD1 to SD2."
