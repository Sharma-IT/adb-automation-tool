#!/bin/bash

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

LOGFILE=script.log

die() {
    printf "\33[2K\r\033[1;31m%s\033[0m\n" "$*" >&2
    exit 1
}

# Function to log message to a file
log() {
    echo "$(date): $@" >> $LOGFILE
}

# Function to check if ADB is installed
check_adb() {
    command -v adb || die "ADB could not be found. Please install it before running this script."
}

# Function to validate device ID
validate_device_id() {
    [ -z "$DEVICE_ID" ] && die "No device ID provided. Exiting."
}

# Function to connect to an Android device
connect_device() {
    adb -s $DEVICE_ID wait-for-device &>> $LOGFILE
    [ $? -ne 0 ] && die "Failed to connect to device $DEVICE_ID"
}

# Function to retrieve device information
get_device_info() {
    adb -s $DEVICE_ID shell getprop ro.product.manufacturer &>> $LOGFILE
    adb -s $DEVICE_ID shell getprop ro.product.model &>> $LOGFILE
    adb -s $DEVICE_ID shell getprop ro.build.version.release &>> $LOGFILE
}

# Function to download data
download_data() {
    adb -s $DEVICE_ID pull $ANDROID_DIR $LOCAL_DIR &>> $LOGFILE
    [ $? -ne 0 ] && die "Failed to download data from $ANDROID_DIR to $LOCAL_DIR"
}

# Function to run custom command
execute_custom_command() {
    local command=$1
    echo -e "${GREEN}Executing command on device $DEVICE_ID: $command${NC}"
    adb -s $DEVICE_ID shell $command &>> $LOGFILE
    
    [ $? -ne 0 ] && die "Failed to execute command $command"
}

# Function to reboot device
reboot_device() {
    echo -e "${RED}Are you sure you want to reboot device $DEVICE_ID? (y/n)${NC}"
    read -r choice

    if [[ $choice =~ ^[Yy]$ ]]; then
        adb -s $DEVICE_ID reboot &>> $LOGFILE
    else
        echo -e "${GREEN}Reboot canceled.${NC}"
    fi
}

# Help function
usage() {
    echo "Usage: $0 [-d DEVICE_ID] [-s SOURCE_DIR] [-t TARGET_DIR] [-c COMMAND]"
    echo "Options:
    -h, --help      Display this help message.
    -d DEVICE_ID    Set the Android device id. Multiple -d options can be used for multiple devices.
    -s SOURCE_DIR   Set the source directory on the Android device.
    -t TARGET_DIR   Set the target directory on local system.
    -c COMMAND      Execute a custom command on the device.
    "
    exit 0
}

# Parse command line arguments
while getopts ":hd:s:t:c:" opt; do
    case ${opt} in
        h )
            usage
            ;;
        d )
        DEVICE_IDS+=("$OPTARG")
        ;;
    s )
        ANDROID_DIR=$OPTARG
        ;;
    t )
        LOCAL_DIR=$OPTARG
        ;;
    c )
        CUSTOM_COMMAND=$OPTARG
        ;;
    \? )
        echo -e "${RED}Invalid Option: -$OPTARG${NC}" 1>&2
        usage
        ;;
    esac
done

# Validate inputs
check_adb

[ -z "$DEVICE_IDS" ] && die "No device IDs provided. Exiting."

[ -z "$ANDROID_DIR" ] || [ -z "$LOCAL_DIR" ] && die "Source or target directory not defined. Exiting."

[ ! -d "$ANDROID_DIR" ] && "Source directory '$ANDROID_DIR' does not exist. Exiting."

[ ! -d "$LOCAL_DIR" ] && mkdir -p "$LOCAL_DIR"

# Function to execute commands in parallel
execute_parallel() {
    local command=$1
    local device_id=$2

    echo -e "${GREEN}Executing command on device $device_id: $command${NC}"
    adb -s $device_id shell $command &>> $LOGFILE

    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to execute command $command on device $device_id${NC}"
    fi
}

# Loop through each device ID and perform operations in parallel
for DEVICE_ID in "${DEVICE_IDS[@]}"; do
    echo "Processing device: $DEVICE_ID"
    log "Processing device: $DEVICE_ID"

    connect_device
    get_device_info
    download_data

    # Additional logic for each device
    if [ -n "$CUSTOM_COMMAND" ]; then
        execute_parallel "$CUSTOM_COMMAND" "$DEVICE_ID"
    fi

    reboot_device
done
