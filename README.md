#  User Management Automation

This project automates the creation and management of Linux user accounts using a Bash script.  
It is designed to work seamlessly on:

- ✔ WSL (Windows Subsystem for Linux)  
- ✔ Real Linux servers (Ubuntu/Debian)

The script reads a simple input file, creates accounts, assigns groups, sets up home directories, generates passwords, and stores logs and passwords inside a Windows-friendly project folder.

---

#  Features

✔ Bulk user creation 

✔ Automatic group creation 

✔ Home directory setup  

✔ Secure 12-character password generation

✔ Passwords saved locally (WSL-safe)  

✔ Detailed timestamped logging  

✔ WSL auto-detection  

✔ Safe re-run behavior (idempotent)

✔ Handles already-existing users gracefully  

---

#  Purpose of the Script

This script automates the onboarding of Linux users using a plain text list. It performs:

- Creation of new user accounts

- Creation of supplementary groups 

- Ensuring home directories exist with secure permissions 

- Generation of strong random passwords  

- Saving username/password pairs in a local secure file  

- Logging all operations with timestamps  

It is useful for:

- DevOps onboarding 

- Sysadmin automation

- Training labs  

- Quick environment setup  

---
# Design Highlights

1. Input format uses the pattern:

    . username;group1,group2,group3

2. Blank lines and lines starting with # are ignored.

3. Whitespace is automatically removed from usernames and groups.

4. Missing groups are created automatically.

5. Existing users:

    . Supplementary groups are added safely without removing existing memberships

    . Home directory permissions are validated

    . Passwords are not overwritten

6.Passwords and logs are stored with restrictive file permissions.

7.The script requires root privileges. 

---
# Project Structure

User Management Automation/

│
├── create_users.sh                          # Main automation script
├── new_users.txt              # Input user list
├── README.md                  # Documentation
│
├── passwords.txt              # Generated passwords (output)
├── user_management.log        # Timestamped logs (output)

# Step-by-Step Explanation

1. Sanity Checks

    .Ensures the script is run as root.

    .Checks that the input file exists.

2. Prepare Secure Locations

    .Creates the project directory (if missing).

    .Creates password and log files with permission 600.

3.Process the Input File

    .Reads the file line by line.

    .Skips blank lines and lines starting with #.

    .Extracts the username and group list.

    .Removes whitespace.

4. Validate Username

    .Must follow the pattern:
       ^[a-z_][a-z0-9_-]{0,30}$

    .Invalid usernames are skipped and logged.

5. Create Missing Groups

    .Runs groupadd for groups that do not already exist.

6. Create or Update User

    .If the user exists:

        .Adds missing groups using usermod -a -G.

        .Creates or fixes home directory and permissions.

        .Skips password changes.

    .If the user does not exist:

        .Creates the user with home directory and shell.

        .Adds supplementary groups.

7. Generate Password

    .Creates a random 12-character password using /dev/urandom.

    .Saves it to passwords.txt.

    .On WSL:

        .Password is not applied to the system.

    .On Linux:

        .Password is applied via chpasswd.

8. Logging

    .Every event is logged with timestamps in user_management.log.

9. Completion

    .A completion message is logged and printed.

---

