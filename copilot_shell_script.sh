#!/usr/bin/env bash
# copilot_shell_script.sh
# Prompts user for an assignment name and updates ASSIGNMENT in config/config.env
set -euo pipefail

read -p "Enter the new assignment name (e.g., Assignment2): " NEW_ASSIGNMENT

# Try to find a config.env file under submission_reminder_* directories
CONFIG_PATH="$(find . -maxdepth 3 -type f -path "./submission_reminder_*/*/config/config.env" -print | head -n1 || true)"

# If not found using that pattern, fallback to any config/config.env found in two levels
if [ -z "$CONFIG_PATH" ]; then
  CONFIG_PATH="$(find . -maxdepth 3 -type f -path "*/config/config.env" -print | head -n1 || true)"
fi

if [ -z "$CONFIG_PATH" ]; then
  echo "config/config.env not found in the repository. Please run this script from the repository root or provide the path."
  read -p "Or enter the full path to config.env: " MANUAL_PATH
  if [ -f "$MANUAL_PATH" ]; then
    CONFIG_PATH="$MANUAL_PATH"
  else
    echo "Provided path is invalid. Exiting."
    exit 1
  fi
fi

# Back up original
cp -v "$CONFIG_PATH" "${CONFIG_PATH}.bak"

# Use sed to replace the ASSIGNMENT line. Handles forms:
# ASSIGNMENT=foo  OR ASSIGNMENT="foo"
# If ASSIGNMENT key doesn't exist, append it.
if grep -qE '^ASSIGNMENT=' "$CONFIG_PATH"; then
  sed -E -i'' -e "s#^ASSIGNMENT=.*#ASSIGNMENT=\"${NEW_ASSIGNMENT}\"#" "$CONFIG_PATH"
else
  echo "ASSIGNMENT=\"${NEW_ASSIGNMENT}\"" >> "$CONFIG_PATH"
fi

echo "Updated ASSIGNMENT in $CONFIG_PATH to: $NEW_ASSIGNMENT"
echo "Backup saved as ${CONFIG_PATH}.bak"
echo "You can now run the app's startup script to check non-submissions (e.g., ./submission_reminder_<yourName>/startup.sh)"
