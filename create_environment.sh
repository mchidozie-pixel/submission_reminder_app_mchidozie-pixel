#!/bin/bash

set -euo pipefail

printf "Enter your name (used to name the environment directory): "
read USERNAME
if [ -z "${USERNAME}" ]; then
  echo "A name is required. Exiting."
  exit 1
fi

TARGET="submission_reminder_${USERNAME}"
if [ -e "$TARGET" ]; then
  echo "Target directory '$TARGET' already exists. Aborting to avoid overwrite."
  exit 1
fi

echo "Creating environment in ./$TARGET"
mkdir -p "$TARGET"/app "$TARGET"/modules "$TARGET"/assets "$TARGET"/config

# Create a tiny PNG placeholder (decoded from base64)
cat > "$TARGET/image.png" <<'PNGBASE64'
iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAASsJTYQAAAAASUVORK5CYII=
PNGBASE64
base64 -d "$TARGET/image.png" > "$TARGET/image.png.tmp" 2>/dev/null || true
if [ -f "$TARGET/image.png.tmp" ]; then mv "$TARGET/image.png.tmp" "$TARGET/image.png"; fi

# app/reminder.sh (from provided content)
cat > "$TARGET/app/reminder.sh" <<'REM'
#!/bin/bash

# Source environment variables and helper functions
source ./config/config.env
source ./modules/functions.sh

# Path to the submissions file
submissions_file="./assets/submissions.txt"

# Allow passing an assignment name as the first argument; fall back to config
assignment_to_check="${1:-$ASSIGNMENT}"

# Print remaining time and run the reminder function
echo "Assignment: $assignment_to_check"
echo "Days remaining to submit: $DAYS_REMAINING days"
echo "--------------------------------------------"

check_submissions "$submissions_file" "$assignment_to_check"
REM

# modules/functions.sh (improved)
cat > "$TARGET/modules/functions.sh" <<'FUN'
#!/bin/bash

# check_submissions <submissions_file> [assignment]
# If assignment is provided it overrides the $ASSIGNMENT from config
function check_submissions {
  local submissions_file=$1
  local assignment=${2:-$ASSIGNMENT}

  echo "Checking submissions in $submissions_file for assignment: $assignment"

  # Skip the header and iterate through the lines
  tail -n +2 "$submissions_file" | while IFS=, read -r student assignment_col status; do
    # Remove leading and trailing whitespace
    student=$(echo "$student" | xargs)
    assignment_col=$(echo "$assignment_col" | xargs)
    status=$(echo "$status" | xargs)

    # Check if assignment matches and report status
    if [ "$assignment_col" = "$assignment" ]; then
      if [ "$status" = "not submitted" ]; then
        echo "Reminder: $student has not submitted the $assignment assignment!"
      else
        echo "OK: $student has submitted the $assignment assignment."
      fi
    fi
  done
}

# list_students <submissions_file> -> prints unique student names (one per line)
function list_students {
  local submissions_file=$1
  tail -n +2 "$submissions_file" | cut -d, -f1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | sort -u
}
FUN

# app/add_assignment.sh: interactive helper to add an assignment for existing students
cat > "$TARGET/app/add_assignment.sh" <<'ADD'
#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SUBMISSIONS_FILE="$SCRIPT_DIR/../assets/submissions.txt"

# load helper functions (list_students)
source "$SCRIPT_DIR/../modules/functions.sh"

assignment="${1:-}"
if [ -z "$assignment" ]; then
  read -p "Enter new assignment name: " assignment
fi
if [ -z "$assignment" ]; then
  echo "No assignment name provided. Exiting."
  exit 1
fi

echo "Adding assignment '$assignment' to $SUBMISSIONS_FILE"

# Ensure header exists
if ! head -n1 "$SUBMISSIONS_FILE" | grep -q "student"; then
  echo "student, assignment, submission status" | cat - "$SUBMISSIONS_FILE" > "$SUBMISSIONS_FILE.tmp" && mv "$SUBMISSIONS_FILE.tmp" "$SUBMISSIONS_FILE"
fi

students=$(list_students "$SUBMISSIONS_FILE")
if [ -z "$students" ]; then
  echo "No existing students found. You can add students now."
  while true; do
    read -p "Enter student name (or leave blank to finish): " s
    [ -z "$s" ] && break
    read -p "Did $s submit '$assignment'? (y/N): " resp
    resp=${resp:-n}
    status="not submitted"
    if [ "$resp" = "y" ] || [ "$resp" = "Y" ]; then status="submitted"; fi
    echo "$s, $assignment, $status" >> "$SUBMISSIONS_FILE"
  done
else
  echo "$students" | while read -r s; do
    read -p "Did $s submit '$assignment'? (y/N): " resp
    resp=${resp:-n}
    status="not submitted"
    if [ "$resp" = "y" ] || [ "$resp" = "Y" ]; then status="submitted"; fi
    echo "$s, $assignment, $status" >> "$SUBMISSIONS_FILE"
  done
fi

echo "Done."
ADD

# config/config.env (from provided content)
cat > "$TARGET/config/config.env" <<'CFG'
# This is the config file
ASSIGNMENT="Shell Navigation"
DAYS_REMAINING=2
CFG

# assets/submissions.txt: include original entries plus >=5 extra students
cat > "$TARGET/assets/submissions.txt" <<'SUB'
student, assignment, submission status
Chinemerem, Shell Navigation, not submitted
Chiagoziem, Git, submitted
Divine, Shell Navigation, not submitted
Anissa, Shell Basics, submitted
Chioma, Shell Navigation, submitted
Gith, Shell Navigation, not submitted
Willi, Shell Navigation, not submitted
Pete, Git, submitted
Paul, Shell Navigation, not submitted
SUB

# startup.sh: start the app from the project root
cat > "$TARGET/startup.sh" <<'START'
#!/bin/bash
# Startup script for submission reminder app
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# Ensure all .sh files are executable
find . -type f -name '*.sh' -exec chmod +x {} \;

echo "Launching the Submission Reminder App..."
./app/reminder.sh
START

# Make all shell scripts executable
find "$TARGET" -type f -name '*.sh' -exec chmod +x {} \;

echo "Created $TARGET with files. Structure:"
tree -a "$TARGET" 2>/dev/null || ls -R "$TARGET"

echo
echo "Running startup.sh to test the app now..."
"$TARGET/startup.sh"

echo
echo "Environment creation finished. To run later:"
echo "  cd $TARGET && ./startup.sh"

echo "Done."
