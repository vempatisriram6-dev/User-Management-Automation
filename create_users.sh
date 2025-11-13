#!/usr/bin/env bash
set -o pipefail

# --------------------------------------------------------------------------------------
# FIXED PATH — YOUR CUSTOM PROJECT FOLDER
# --------------------------------------------------------------------------------------
PROJECT_DIR="/mnt/c/Users/vempa/OneDrive/Desktop/User Management Automation"
PASSWORD_FILE="$PROJECT_DIR/passwords.txt"
LOG_FILE="$PROJECT_DIR/user_management.log"
INPUT_FILE="$1"

# --------------------------------------------------------------------------------------
# Ensure project directory exists
# --------------------------------------------------------------------------------------
mkdir -p "$PROJECT_DIR"

# Detect WSL
if grep -qi microsoft /proc/version 2>/dev/null; then
    IS_WSL=true
else
    IS_WSL=false
fi

# Must run as root
if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Run the script with sudo."
  exit 1
fi

# Validate input file
if [[ -z "$INPUT_FILE" || ! -f "$INPUT_FILE" ]]; then
  echo "Usage: $0 <users_file>"
  exit 1
fi

# --------------------------------------------------------------------------------------
# Create password + log files
# --------------------------------------------------------------------------------------
touch "$PASSWORD_FILE"
chmod 600 "$PASSWORD_FILE"

touch "$LOG_FILE"
chmod 600 "$LOG_FILE"

log() {
    local ts msg
    ts="$(date '+%Y-%m-%d %H:%M:%S')"
    msg="$ts - $1"
    echo "$msg" | tee -a "$LOG_FILE"
}

generate_password() {
    tr -dc 'A-Za-z0-9-_.!@#' < /dev/urandom | head -c 12
}

trim() {
    echo "$1" | tr -d '[:space:]'
}

log "===== Starting User Provisioning ====="
log "Password file path: $PASSWORD_FILE"
log "Log file path: $LOG_FILE"

# --------------------------------------------------------------------------------------
# MAIN LOOP
# --------------------------------------------------------------------------------------
while IFS= read -r raw_line || [[ -n "$raw_line" ]]; do

    # Remove whitespace
    line="$(trim "$raw_line")"

    # Skip empty or comment lines
    [[ -z "$line" ]] && continue
    [[ "${line:0:1}" == "#" ]] && continue

    if [[ "$line" != *";"* ]]; then
        log "SKIP: Invalid line → $raw_line"
        continue
    fi

    username="${line%%;*}"
    group_list="${line#*;}"

    # Validate username
    if ! [[ "$username" =~ ^[a-z_][a-z0-9_-]{0,30}$ ]]; then
        log "SKIP invalid username: $username"
        continue
    fi

    log "Processing user: $username"

    # Prepare groups
    IFS=',' read -ra GROUPS <<< "$group_list"
    for grp in "${GROUPS[@]}"; do
        [[ -z "$grp" ]] && continue
        if ! getent group "$grp" >/dev/null; then
            groupadd "$grp"
            log "Created group: $grp"
        fi
    done

    # If user exists already
    if id "$username" >/dev/null 2>&1; then
        log "User exists → updating"

        # Ensure group membership
        for grp in "${GROUPS[@]}"; do
            [[ -z "$grp" ]] && continue
            usermod -a -G "$grp" "$username"
            log "Added $username to $grp"
        done

        home="/home/$username"
        mkdir -p "$home"
        chown "$username:$username" "$home"
        chmod 700 "$home"
        log "Home fixed"

        log "SKIP: No password change for existing user"
        continue
    fi

    # Create NEW user
    if [[ -n "$group_list" ]]; then
        useradd -m -s /bin/bash -G "$group_list" "$username"
    else
        useradd -m -s /bin/bash "$username"
    fi

    log "Created user: $username"

    # Fix home directory
    home="/home/$username"
    chown "$username:$username" "$home"
    chmod 700 "$home"

    # Generate password ALWAYS
    password="$(generate_password)"
    log "Generated password for $username: $password"

    # Save password ALWAYS
    echo "$username:$password" >> "$PASSWORD_FILE"
    log "Saved password to file"

    # Apply password on Linux only
    if [[ "$IS_WSL" == true ]]; then
        log "WSL detected → password NOT applied"
    else
        echo "$username:$password" | chpasswd
        log "Password applied on system"
    fi

done < "$INPUT_FILE"

log "===== User Provisioning Completed ====="
exit 0
