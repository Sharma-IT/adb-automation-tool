{\rtf1\ansi\ansicpg1252\cocoartf2707
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fnil\fcharset0 HelveticaNeue;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\deftab560
\pard\pardeftab560\slleading20\partightenfactor0

\f0\fs26 \cf0 #!/bin/bash\
\
# ANSI color codes\
RED='\\033[0;31m'\
GREEN='\\033[0;32m'\
NC='\\033[0m' # No Color\
\
LOGFILE=script.log\
\
# Function to log message to a file\
log() \{\
    echo "$(date): $@" >> $LOGFILE\
\}\
\
# Function to check if ADB is installed\
check_adb() \{\
    if ! command -v adb &> /dev/null; then\
        echo -e "$\{RED\}ADB could not be found. Please install it before running this script.$\{NC\}"\
        exit\
    fi\
\}\
\
# Function to validate device ID\
validate_device_id() \{\
    if [ -z "$DEVICE_ID" ]; then\
        echo -e "$\{RED\}No device ID provided. Exiting.$\{NC\}"\
        exit 1\
    fi\
\}\
\
# Function to connect to an Android device\
connect_device() \{\
    adb -s $DEVICE_ID wait-for-device &>> $LOGFILE\
\
    if [ $? -ne 0 ]; then\
        echo -e "$\{RED\}Failed to connect to device $DEVICE_ID$\{NC\}"\
        exit 1\
    fi\
\}\
\
# Function to retrieve device information\
get_device_info() \{\
    adb -s $DEVICE_ID shell getprop ro.product.manufacturer &>> $LOGFILE\
    adb -s $DEVICE_ID shell getprop ro.product.model &>> $LOGFILE\
    adb -s $DEVICE_ID shell getprop ro.build.version.release &>> $LOGFILE\
\}\
\
# Function to download data\
download_data() \{\
    adb -s $DEVICE_ID pull $ANDROID_DIR $LOCAL_DIR &>> $LOGFILE\
\
    if [ $? -ne 0 ]; then\
        echo -e "$\{RED\}Failed to download data from $ANDROID_DIR to $LOCAL_DIR$\{NC\}"\
        exit 1\
    fi\
\}\
\
# Function to run custom command\
execute_custom_command() \{\
    local command=$1\
    echo -e "$\{GREEN\}Executing command on device $DEVICE_ID: $command$\{NC\}"\
    adb -s $DEVICE_ID shell $command &>> $LOGFILE\
    \
    if [ $? -ne 0 ]; then\
        echo -e "$\{RED\}Failed to execute command $command$\{NC\}"\
    fi\
\}\
\
# Function to reboot device\
reboot_device() \{\
    echo -e "$\{RED\}Are you sure you want to reboot device $DEVICE_ID? (y/n)$\{NC\}"\
    read -r choice\
\
    if [[ $choice =~ ^[Yy]$ ]]; then\
        adb -s $DEVICE_ID reboot &>> $LOGFILE\
    else\
        echo -e "$\{GREEN\}Reboot canceled.$\{NC\}"\
    fi\
\}\
\
# Help function\
usage() \{\
    echo "Usage: $0 [-d DEVICE_ID] [-s SOURCE_DIR] [-t TARGET_DIR] [-c COMMAND]"\
    echo "Options:\
    -h, --help      Display this help message.\
    -d DEVICE_ID    Set the Android device id. Multiple -d options can be used for multiple devices.\
    -s SOURCE_DIR   Set the source directory on the Android device.\
    -t TARGET_DIR   Set the target directory on local system.\
    -c COMMAND      Execute a custom command on the device.\
    "\
    exit 0\
\}\
\
# Parse command line arguments\
while getopts ":hd:s:t:c:" opt; do\
    case $\{opt\} in\
        h )\
            usage\
            ;;\
        d )\
        DEVICE_IDS+=("$OPTARG")\
        ;;\
    s )\
        ANDROID_DIR=$OPTARG\
        ;;\
    t )\
        LOCAL_DIR=$OPTARG\
        ;;\
    c )\
        CUSTOM_COMMAND=$OPTARG\
        ;;\
    \\? )\
        echo -e "$\{RED\}Invalid Option: -$OPTARG$\{NC\}" 1>&2\
        usage\
        ;;\
    esac\
done\
\
# Validate inputs\
check_adb\
\
if [ -z "$DEVICE_IDS" ]; then\
    echo -e "$\{RED\}No device IDs provided. Exiting.$\{NC\}"\
    exit 1\
fi\
\
if [ -z "$ANDROID_DIR" ] || [ -z "$LOCAL_DIR" ]; then\
    echo -e "$\{RED\}Source or target directory not defined. Exiting.$\{NC\}"\
    exit 1\
fi\
\
if [ ! -d "$ANDROID_DIR" ]; then\
    echo -e "$\{RED\}Source directory '$ANDROID_DIR' does not exist. Exiting.$\{NC\}"\
    exit 1\
fi\
\
if [ ! -d "$LOCAL_DIR" ]; then\
    mkdir -p "$LOCAL_DIR"\
fi\
\
# Function to execute commands in parallel\
execute_parallel() \{\
    local command=$1\
    local device_id=$2\
\
    echo -e "$\{GREEN\}Executing command on device $device_id: $command$\{NC\}"\
    adb -s $device_id shell $command &>> $LOGFILE\
\
    if [ $? -ne 0 ]; then\
        echo -e "$\{RED\}Failed to execute command $command on device $device_id$\{NC\}"\
    fi\
\}\
\
# Loop through each device ID and perform operations in parallel\
for DEVICE_ID in "$\{DEVICE_IDS[@]\}"; do\
    echo "Processing device: $DEVICE_ID"\
    log "Processing device: $DEVICE_ID"\
\
    connect_device\
    get_device_info\
    download_data\
\
    # Additional logic for each device\
    if [ -n "$CUSTOM_COMMAND" ]; then\
        execute_parallel "$CUSTOM_COMMAND" "$DEVICE_ID"\
    fi\
\
    reboot_device\
done}