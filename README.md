Submission Reminder App
This repository contains two primary shell scripts designed to set up and manage a simple submission reminder application environment.

1. Prerequisites
You must have a Unix-like environment (Linux, macOS, or WSL) with bash and standard utilities (mkdir, echo, cat, chmod, read, find, sed) installed.

2. Setup (Task 1)
The create_environment.sh script handles the initial setup of the application's directory structure and required files.

To run the setup script:

sh create_environment.sh

The script will prompt you to enter your name.

It will create a directory named submission_reminder_{yourName}.

It will populate all necessary files (reminder.sh, functions.sh, config.env, submissions.txt, and startup.sh).

It sets the executable permissions for all .sh files.

It automatically runs the newly created startup.sh script to confirm the setup is working.

3. Running the Application
The application is run via the startup.sh script located in the root of the created application directory.

Assuming your name is 'John' and you are in the directory containing submission_reminder_John:

sh submission_reminder_John/startup.sh

4. Modifying the Target Assignment (Task 2)
The copilot_shell_script.sh allows you to easily update the assignment name being checked in the application's configuration without manual editing.

To run the copilot script:

sh copilot_shell_script.sh

The script will attempt to detect your application directory (submission_reminder_*).

It will prompt you to enter a new assignment name (e.g., Assignment 1 or Assignment 2). This input automatically updates the ASSIGNMENT variable in config/config.env.

It then automatically re-runs the startup.sh script to check the submission status against the new configuration.

5. Git Branching Workflow (Task 3)
The goal of the workflow is to keep the final main branch clean, containing only the executable scripts and the README.

Required Files in Final main Branch:

create_environment.sh

copilot_shell_script.sh

README.md

Recommended Workflow Steps:

Create Development Branch: Start all your work on a new feature branch:

git checkout -b feature/setup

Ensure Cleanup: Add a .gitignore file to ignore the generated application directory (submission_reminder_*) so it isn't accidentally committed.

echo "submission_reminder_*" >> .gitignore
git add .gitignore
git commit -m "Add gitignore for generated app folders."

Perform Testing: Run the setup script to test the application environment on this feature branch:

sh create_environment.sh

Merge to Main: Once testing is complete and only the required files are committed, switch back to main and merge your changes:

git checkout main
git merge feature/setup

