#!/bin/bash
# Startup script for submission reminder app
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# Ensure all .sh files are executable
find . -type f -name '*.sh' -exec chmod +x {} \;

echo "Launching the Submission Reminder App..."
./app/reminder.sh
