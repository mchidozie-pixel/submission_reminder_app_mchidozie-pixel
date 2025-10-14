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
