#!/bin/bash
# Entry script to start Xvfb and set display
set -e

# Set sensible defaults for env variables that can be overridden while running
# the container
DEFAULT_LOG_LEVEL="INFO"
DEFAULT_RES="1366x768x24"
DEFAULT_DISPLAY=":99"

# Use default if none specified as env var
LOG_LEVEL=${LOG_LEVEL:-$DEFAULT_LOG_LEVEL}
RES=${RES:-$DEFAULT_RES}
DISPLAY=${DISPLAY:-$DEFAULT_DISPLAY}

# Process optional parameters passed to robot
OPTIONAL_PARAMETERS=""

# Start Xvfb
echo -e "Starting Xvfb on display ${DISPLAY} with res ${RES}"
Xvfb ${DISPLAY} -ac -screen 0 ${RES} +extension RANDR &
export DISPLAY=${DISPLAY}

# Execute tests
echo -e "Executing robot tests, parameters ${OPTIONAL_PARAMETERS}"
robot --listener listeners/KitsuListener.py -d reports tests/

# Stop Xvfb
kill -9 $(pgrep Xvfb)