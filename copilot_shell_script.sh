#!/bin/bash
# copilot_shell_script.sh
# Task 2: Prompts for a new assignment name, updates the config file, and reruns the app.

# --- 1. Locate the Application Directory ---
# Attempt to auto-detect the app directory
APP_DIR_CANDIDATES=$(find . -maxdepth 1 -type d -name "submission_reminder_*" -print -quit)

if [ -n "$APP_DIR_CANDIDATES" ]; then
    APP_DIR=$(basename "$APP_DIR_CANDIDATES")
    echo "Detected application directory: $APP_DIR"
else
    # If not found, prompt the user
    read -p "No application directory found. Please enter the name of your app directory (e.g., submission_reminder_John): " APP_DIR
    if [ ! -d "$APP_DIR" ]; then
        echo "Error: Directory '$APP_DIR' not found."
        exit 1
    fi
fi

CONFIG_FILE="$APP_DIR/config/config.env"
STARTUP_SCRIPT="$APP_DIR/startup.sh"

# Check required files
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file not found at $CONFIG_FILE"
    exit 1
fi
if [ ! -f "$STARTUP_SCRIPT" ]; then
    echo "Error: Startup script not found at $STARTUP_SCRIPT"
    exit 1
fi

# --- 2. Prompt for new assignment name ---
read -p "Enter the new assignment name to check (e.g., Midterm Exam): " new_assignment_name

# Check if the input is empty
if [ -z "$new_assignment_name" ]; then
    echo "Assignment name cannot be empty. Aborting."
    exit 1
fi

# --- 3. Update config.env using sed ---
echo "Updating configuration for ASSIGNMENT to '$new_assignment_name' in $CONFIG_FILE..."

# Use sed for in-place replacement of the ASSIGNMENT line.
# Note: The .bak extension is used for cross-platform compatibility with -i (especially on macOS).
# The pattern ^ASSIGNMENT=.*$ matches the entire line starting with ASSIGNMENT=
sed -i.bak "s/^ASSIGNMENT=.*$/ASSIGNMENT=\"$new_assignment_name\"/" "$CONFIG_FILE"

# Clean up the backup file created by sed (if any)
rm -f "$CONFIG_FILE.bak"

echo "Configuration updated successfully."

# --- 4. Rerun startup.sh ---
echo "Rerunning the Submission Reminder App with the new assignment: '$new_assignment_name'"
sh "$STARTUP_SCRIPT"

echo "Copilot script execution complete."

