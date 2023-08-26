#!/bin/bash

# Include utility functions
source utils.sh

# Load config file if exists
[ -f config.sh ] && source config.sh

# Help function
usage() {
  echo "Usage: $0 [options]"
  echo "Options:
    -h, --help      Display this help message.
    -d DEVICE_ID    Set the Android device id.
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
      devices+=("$OPTARG")
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
      echo -e "${BOLDRED}Invalid Option: -$OPTARG${NC}" 1>&2
      usage
      ;;
  esac
done

# Validate inputs
check_adb

[ ${#devices[@]} -eq 0 ] && print_error "No device IDs provided. Exiting."

validate_dirs

# Function to execute commands in parallel with a limit on concurrent processes
execute_parallel_limit() {
  local command="$1"
  local device_id="$2"
  echo -e "${BOLDGREEN}Executing command on device $device_id: $command${NC}"
  adb_execute "shell $command"
}

# Maximum number of concurrent processes
MAX_CONCURRENT_PROCESSES=3
current_jobs=0

# Loop through each device ID and perform operations in parallel
for DEVICE_ID in "${devices[@]}"; do
  echo "Processing device: $DEVICE_ID"
  log "Processing device: $DEVICE_ID"

  validate_device_id
  connect_device
  get_device_info
  download_data

  # Additional logic for each device
  if [ -n "$CUSTOM_COMMAND" ]; then
    execute_parallel_limit "$CUSTOM_COMMAND" "$DEVICE_ID" &
    ((current_jobs++))
    while [ "$current_jobs" -ge "$MAX_CONCURRENT_PROCESSES" ]; do
      wait -n
      ((current_jobs--))
    done
  fi

  reboot_device &
  ((current_jobs++))
  while [ "$current_jobs" -ge "$MAX_CONCURRENT_PROCESSES" ]; do
    wait -n
    ((current_jobs--))
  done
done

# Wait for all background processes to finish
wait