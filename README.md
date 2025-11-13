#  User Management Automation

This project automates the creation and management of Linux user accounts using a Bash script.  
It is designed to work seamlessly on:

-  ► WSL (Windows Subsystem for Linux)  
-  ► Real Linux servers (Ubuntu/Debian)

The script reads a simple input file, creates accounts, assigns groups, sets up home directories, generates passwords, and stores logs and passwords inside a Windows-friendly project folder.

---

#  Features

✦ Bulk user creation 

✦ Automatic group creation 

✦ Home directory setup  

✦ Secure 12-character password generation

✦ Passwords saved locally (WSL-safe)  

✦ Detailed timestamped logging  

✦ WSL auto-detection  

✦ Safe re-run behavior (idempotent)

✦ Handles already-existing users gracefully  

---

#  Purpose of the Script

This script automates the onboarding of Linux users using a plain text list. 

It performs:

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

     ● username;group1,group2,group3

2. Blank lines and lines starting with # are ignored.

3. Whitespace is automatically removed from usernames and groups.

4. Missing groups are created automatically.

5. Existing users:

    ● Supplementary groups are added safely without removing existing memberships

    ● Home directory permissions are validated

    ● Passwords are not overwritten

6.Passwords and logs are stored with restrictive file permissions.

7.The script requires root privileges. 

---

# Project Structure

```text
User Management Automation/
│
├── create_users.sh              # Main automation script
├── new_users.txt                # Input file containing usernames and groups
├── README.md                    # Documentation for the project
│
├── passwords.txt                # Output: generated passwords for new users
└── user_management.log          # Output: timestamped log of all operations
```

---
# Step-by-Step Explanation

1. # Sanity Checks

    ● Ensures the script is run as root.

    ● Checks that the input file exists.

2. # Prepare Secure Locations

    ● Creates the project directory (if missing).

    ● Creates password and log files with permission 600.

3.  # Process the Input File

    ● Reads the file line by line.
    
    ● Skips blank lines and lines starting with #.

    ● Extracts the username and group list.

    ● Removes whitespace.

4. # Validate Username

    ● Must follow the pattern:
   
       ^[a-z_][a-z0-9_-]{0,30}$

    ● Invalid usernames are skipped and logged.

6. # Create Missing Groups

    ● Runs groupadd for groups that do not already exist.

7. # Create or Update User

    ● If the user exists:

        ● Adds missing groups using usermod -a -G.

        ● Creates or fixes home directory and permissions.

        ● Skips password changes.

    ● If the user does not exist:

        ● Creates the user with home directory and shell.

        ● Adds supplementary groups.
        
        

8. # Generate Password

     ● Creates a random 12-character password using /dev/urandom.

     ● Saves it to passwords.txt.

     ● On WSL:

         ● Password is not applied to the system.

     ● On Linux:

         ● Password is applied via chpasswd.

9. # Logging

     ● Every event is logged with timestamps in user_management.log.

10. # Completion

    ● A completion message is logged and printed.

---
# Example Input (new_users.txt)

#username;groups

light; sudo, dev, www-data

siyoni; sudo

manoj; dev, www-data

manojkumar; dev, www-data

sriram; dev, www-data

---
# Example Output

2025-11-13 09:24:39 - ===== Starting User Provisioning =====

2025-11-13 09:24:39 - Password file path: /mnt/c/Users/vempa/OneDrive/Desktop/User Management Automation/passwords.txt

2025-11-13 09:24:39 - Log file path: /mnt/c/Users/vempa/OneDrive/Desktop/User Management Automation/user_management.log

2025-11-13 09:24:39 - Processing user: light

2025-11-13 09:24:39 - User exists → updating

2025-11-13 09:24:40 - Home fixed

2025-11-13 09:24:40 - SKIP: No password change for existing user

2025-11-13 09:24:40 - Processing user: siyoni

2025-11-13 09:24:40 - User exists → updating

2025-11-13 09:24:40 - Home fixed

2025-11-13 09:24:40 - SKIP: No password change for existing user

2025-11-13 09:24:40 - Processing user: manoj

2025-11-13 09:24:40 - User exists → updating

2025-11-13 09:24:40 - Home fixed

2025-11-13 09:24:40 - SKIP: No password change for existing user


2025-11-13 09:24:40 - Processing user: manojkumar

2025-11-13 09:24:40 - User exists → updating

2025-11-13 09:24:40 - Home fixed

2025-11-13 09:24:40 - SKIP: No password change for existing user

2025-11-13 09:24:40 - Processing user: sriram

2025-11-13 09:24:40 - Created user: sriram

2025-11-13 09:24:40 - Generated password for sriram: LG0UK.Pf1uH0

2025-11-13 09:24:40 - Saved password to file

2025-11-13 09:24:40 - WSL detected → password NOT applied

2025-11-13 09:24:40 - ===== User Provisioning Completed =====

---
# password.txt

🗸 manojkumar:wD2Ye9IU04ym

🗸 sriram:7Sg8qTqhNB5D

🗸 sriram:LG0UK.Pf1uH0

---
# Example Use Cases

✪ Automating onboarding for new developers.

✪ DevOps and system administration training.

✪ Bulk user creation in lab environments.

✪ Quickly preparing users for testing environments.

---

# Security Considerations

1. # Plaintext Password Storage

   Passwords are stored in plaintext because the project requires it.

Mitigations:

    ● File permissions set to 600.

    ● Only root can access the file.

    ● Consider using a secrets manager for production use.

2. # Password Usage

   You may force password changes on first login using:

    ● change -d 0 <username>


3. # Password Generation

    Passwords are generated with high entropy using /dev/urandom.

4. # Logging

    ● Logs do not contain passwords.

    ● Consider configuring log rotation for long-term usage.

5. # Root Privileges

    ● The script modifies system accounts and must be run with sudo.


---

# Running the Script

```bash
cd "/mnt/c/Users/vempa/OneDrive/Desktop/User Management Automation"
chmod +x create_users.sh
sudo ./create_users.sh new_users.txt
```
---
# Author
```
**Name:** vempati sriram  
**Project:** User Management Automation  
**GitHub Repository:** https://github.com/vempatisriram6-dev/User-Management-Automation
```
---

