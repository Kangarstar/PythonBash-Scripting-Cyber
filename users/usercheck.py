#!/usr/bin/env python3

import os
import pwd
import subprocess
import re
from datetime import datetime
from pathlib import Path

# Root check
if os.geteuid() != 0:
    print("This script must be run as root")
    exit(1)

# Log file path and date
timestamp = datetime.now().strftime("%d-%m-%Y_%H:%M:%S")
LOG_DIR = "/var/log/security"
LOG_FILE = f"{LOG_DIR}/user_check.py_{timestamp}.log"

# Check log directory exists
Path(LOG_DIR).mkdir(parents=True, exist_ok=True)

# Prompt
print("----------------------------------------")
print("Checking login status for all users...")
print("----------------------------------------")

# Logs
with open(LOG_FILE, "w") as log:
    log.write("=========================================\n")
    log.write("====   Useless users status check    ====\n")
    log.write("=========================================\n")

# Regular users count
user_count = 0

# Process all users
for user in pwd.getpwall():
    username = user.pw_name
    uid = user.pw_uid
    home = user.pw_dir
    shell = user.pw_shell
    
    # Skip system users and nologin/false shells
    if (uid >= 1000 and 
            shell != "/usr/sbin/nologin" and 
            shell != "/bin/false"):
        
        user_count += 1
        
        # Display on screen
        print(f"Found User: {username} (UID: {uid})")
        
        # Check if user is logged in
        who_output = subprocess.run(["who"], capture_output=True, text=True).stdout
        logged_in_count = len(re.findall(f"^{username} ", who_output, re.MULTILINE))
        
        # Write to log
        with open(LOG_FILE, "a") as log:
            log.write(f"User: {username}\n")
            log.write(f"UID: {uid}\n")
            log.write(f"Home Directory: {home}\n")
            log.write(f"Shell: {shell}\n")
            log.write(f"Status: {logged_in_count}\n")

# Prompt summary
print("----------------------------------------")
print(f"Total users who have logged in: {user_count}")
print(f"Check completed at: {timestamp}")
print(f"Log file created at: {LOG_FILE}")
print("----------------------------------------")

# Write summary to log
with open(LOG_FILE, "a") as log:
    log.write("----------------------------------------\n")
    log.write(f"Total users who have logged in: {user_count}\n")
    log.write("----------------------------------------\n")
    log.write(f"Check completed at: {timestamp}\n")
    log.write("========================================\n")
    log.write("vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv\n")

# Set appropriate permissions
os.chmod(LOG_FILE, 0o600)

exit(0)