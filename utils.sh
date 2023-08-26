#!/bin/bash

# ANSI color codes
BOLDRED='\033[1;31m'
BOLDGREEN='\033[1;32m'
BOLDYELLOW='\033[1;33m'
NC='\033[0m' # No Color

LOGFILE=script.log
ERRORLOG=errors.log

# Function to print error message with timestamp to stderr and log file, and exit with stack trace
print_error() {
  local message="$1"
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo "$timestamp: $message" >> "$ERRORLOG"
  printf "%s: ${BOLDRED}%s${NC}\n" "$timestamp" "$message" >&2
  print_stack_trace
  exit 1
}

# Function to print stack trace
print_stack_trace() {
  echo "Stack trace:" >&2
  for ((i=${#BASH_SOURCE[@]}-1; i>=0; i--)); do
    echo " ${BASH_SOURCE[i]}:${BASH_LINENO[i]}" >&2
  done
}

# Function to log message to a file
log() {
  local message="$1"
  echo "$(date): $message" >> "$LOGFILE"
}

# Function to execute adb command and handle errors
adb_execute() {
  local command="$1"
  adb_command="adb -s $DEVICE_ID $command"
  log "Executing: $adb_command"
  eval "$adb_command" &>> "$LOGFILE"
  if [ $? -ne 0 ]; then
    print_error "Failed to execute: $adb_command"
  fi
}

# Function to validate device ID
validate_device_id() {
  [ -z "$DEVICE_ID" ] && print_error "No device ID provided. Exiting."
}

# Function to validate source and target directories
validate_dirs() {
  [ -z "$ANDROID_DIR" ] || [ -z "$LOCAL_DIR" ] && print_error "Source or target directory not defined. Exiting."
  [ ! -d "$ANDROID_DIR" ] && print_error "Source directory '$ANDROID_DIR' does not exist. Exiting."
  [ ! -d "$LOCAL_DIR" ] && mkdir -p "$LOCAL_DIR"
}

# Function to execute commands in parallel
execute_parallel() {
  local command="$1"
  local device_id="$2"
  echo -e "${BOLDGREEN}Executing command on device $device_id: $command${NC}"
  adb_execute "shell $command"
}