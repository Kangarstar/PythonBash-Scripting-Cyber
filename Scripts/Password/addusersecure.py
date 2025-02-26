#!/usr/bin/env python3

import os
import re
import sys
import pwd
import subprocess
import requests
from datetime import datetime
from pathlib import Path

# Colors for terminal output
class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'  # Using yellow for orange
    NC = '\033[0m'  # No Color

# Log file path and date
timestamp = datetime.now().strftime("%d-%m-%Y_%H:%M:%S")
LOG_DIR = "/var/log/security"
LOG_FILE = f"{LOG_DIR}/adduser_secure_{timestamp}.log"
ROCKYOU_DIR = "/home/wordlists"
ROCKYOU_FILE = f"{ROCKYOU_DIR}/rockyou.txt"
ROCKYOU_URL = "https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt"

def run_command(command):
    """Execute a shell command and return its output"""
    try:
        output = subprocess.check_output(command, shell=True, text=True, stderr=subprocess.PIPE)
        return output
    except subprocess.CalledProcessError as e:
        return f"Error executing {command}: {e.stderr}"

def write_to_log(text, color=None, log_only=False):
    """Write text to both console and log file"""
    if not log_only:
        if color:
            print(f"{color}{text}{Colors.NC}")
        else:
            print(text)
    
    with open(LOG_FILE, 'a') as log:
        # Strip color codes for log file
        clean_text = re.sub(r'\033\[[0-9;]+m', '', text)
        log.write(f"[{datetime.now().strftime('%d-%m-%Y_%H:%M:%S')}] {clean_text}\n")

def get_input(prompt, color=Colors.YELLOW):
    """Get user input with colored prompt"""
    print(f"{color}{prompt}{Colors.NC}", end='')
    return input()

def download_rockyou():
    """Download rockyou.txt if not present"""
    if not os.path.isfile(ROCKYOU_FILE):
        write_to_log(f"{ROCKYOU_FILE} not found. Downloading...", Colors.YELLOW, log_only=True)
        try:
            response = requests.get(ROCKYOU_URL, stream=True)
            with open(ROCKYOU_FILE, 'wb') as f:
                for chunk in response.iter_content(chunk_size=8192):
                    f.write(chunk)
            write_to_log(f"Download complete.", Colors.GREEN, log_only=True)
            return True
        except Exception as e:
            write_to_log(f"Download failed! Exiting. Error: {e}", Colors.RED)
            return False
    else:
        write_to_log(f"Using existing rockyou.txt wordlist", Colors.YELLOW, log_only=True)
        return True

def check_password_in_rockyou(password):
    """Check if password is in rockyou.txt"""
    # Clean the password: remove non-alphanumeric characters
    cleaned_password = re.sub(r'[^a-zA-Z0-9]', '', password)
    write_to_log(f"Searching for match in rockyou.txt...", Colors.YELLOW)

    # Search for exact match in rockyou.txt
    password_found = False
    similar_found = False
    line_number = 0

    with open(ROCKYOU_FILE, 'r', errors='ignore') as file:
        for i, line in enumerate(file, 1):
            stripped_line = line.strip()
            if stripped_line.lower() == cleaned_password.lower():
                password_found = True
                line_number = i
                break

    if not password_found:
        # Search for similar passwords
        with open(ROCKYOU_FILE, 'r', errors='ignore') as file:
            for line in file:
                stripped_line = line.strip()
                if cleaned_password.lower() in stripped_line.lower():
                    similar_found = True
                    break

    if password_found:
        write_to_log(f"WARNING: Cleaned password found in RockYou list at line {line_number}", Colors.RED)
        write_to_log(f"This password is considered compromised and should not be used!", Colors.RED)
        return False
    elif similar_found:
        write_to_log(f"WARNING: A similar password found in RockYou list!", Colors.YELLOW)
        write_to_log(f"A password similar to yours was found, it may still be compromised.", Colors.YELLOW)
        return False
    else:
        write_to_log(f"Password not found in RockYou list.", Colors.GREEN)
        write_to_log(f"Note: This doesn't guarantee the password is secure, just that it's not in this specific list.", Colors.YELLOW)
        return True

def validate_password(password):
    """Validate password strength"""
    if not password or len(password) < 12:
        write_to_log(f"Password can't be empty, must contain at least 12 characters long, with uppercase and lower characters, a number and special character.", Colors.RED)
        return False
    
    # Check for uppercase and lowercase letters
    if not (re.search(r'[a-z]', password) and re.search(r'[A-Z]', password)):
        write_to_log(f"Weak: Password must contain both uppercase and lowercase letters", Colors.RED)
        return False
    
    # Check for at least one special character and at least a numeric character
    if not (re.search(r'[^a-zA-Z0-9]', password) and re.search(r'[0-9]', password)):
        write_to_log(f"Weak: Password must contain a number and at least one special character ¨£$¤²%µ*<>?,.;:/§!&~\"#'{{([-+|_\\^@=])}}\\`", Colors.RED)
        return False
    
    write_to_log(f"Your password passes security requirements.", Colors.GREEN)
    return True

def create_user(username, password):
    """Create a new user with the given username and password"""
    write_to_log(f"Creating user account...", Colors.GREEN)
    
    # Create user with home directory
    result = run_command(f"useradd -m {username}")
    if "Error" in result:
        write_to_log(f"Failed to create user: {result}", Colors.RED)
        return False
    
    # Set password
    try:
        passwd_proc = subprocess.Popen(['chpasswd'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        stdout, stderr = passwd_proc.communicate(input=f"{username}:{password}")
        
        if passwd_proc.returncode != 0:
            write_to_log(f"Failed to set password: {stderr}", Colors.RED)
            return False
        
        # Confirmation message
        write_to_log(f"The user '{username}' was successfully created.", Colors.GREEN)
        return True
    except Exception as e:
        write_to_log(f"Failed to set password: {str(e)}", Colors.RED)
        return False

def main():
    # Check if running as root
    if os.geteuid() != 0:
        print(f"{Colors.RED}This script must be run as root{Colors.NC}")
        sys.exit(1)

    # Create directories if they don't exist
    Path(LOG_DIR).mkdir(parents=True, exist_ok=True)
    Path(ROCKYOU_DIR).mkdir(parents=True, exist_ok=True)

    # Initialize log file
    with open(LOG_FILE, "w") as log:
        log.write(f"[{timestamp}] Script executed by {os.getlogin()}\n")

    # Set proper permissions on log file
    os.chmod(LOG_FILE, 0o600)

    # Get username with colored prompt
    username = get_input("Enter username to create : ")

    # Check if username is empty or already exists
    try:
        pwd.getpwnam(username)
        user_exists = True
    except KeyError:
        user_exists = False

    if user_exists or not username:
        write_to_log(f"Caution : Username can't be empty or already exists.", Colors.RED)
        write_to_log(f"Failed to create user: '{username}' - empty or already exists")
        sys.exit(1)

    # Get password with colored prompt
    password = get_input("Enter your password: ")
    
    # Validate password strength
    if not validate_password(password):
        sys.exit(1)
    
    # Confirm password with colored prompt
    password1 = get_input("Please confirm the password : ")
    
    if password != password1:
        write_to_log(f"The passwords entered are not the same. Please retry.", Colors.RED)
        sys.exit(1)

    # Download rockyou.txt if needed
    if not download_rockyou():
        sys.exit(1)

    # Check if password is in rockyou.txt
    if not check_password_in_rockyou(password):
        write_to_log(f"Password check failed for user '{username}' - found in rockyou.txt")
        sys.exit(1)
    
    # Create the user
    if create_user(username, password):
        write_to_log(f"User '{username}' created successfully by {os.getlogin()}", log_only=True)
    else:
        sys.exit(1)
        
    # Complete
    write_to_log("Script completed successfully", Colors.GREEN)
    write_to_log(f"Log saved to: {LOG_FILE}", Colors.YELLOW)

if __name__ == "__main__":
    main()