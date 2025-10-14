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
