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
