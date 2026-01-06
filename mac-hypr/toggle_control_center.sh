#!/bin/bash

# Toggle Control Center for HyprMac
# This script sends a signal to toggle the control center

# Find the Python process running main.py
PYTHON_PID=$(pgrep -f "python.*main.py")

if [ -n "$PYTHON_PID" ]; then
    # Send SIGUSR1 signal to toggle control center
    kill -USR1 "$PYTHON_PID"
else
    # If not running, start it
    ~/.config/mac-hypr/main.py &
fi