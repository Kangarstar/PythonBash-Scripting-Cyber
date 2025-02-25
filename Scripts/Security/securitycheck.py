#!/usr/bin/env python3

import os
import subprocess
import datetime
from pathlib import Path

# Colors for terminal output
class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    NC = '\033[0m'  # No Color

# Log file path
LOG_DIR = "/home/log"
timestamp = datetime.datetime.now().strftime("%d-%m-%Y_%H:%M:%S")
LOG_FILE = f"{LOG_DIR}/security_check.py_{timestamp}.log"

def run_command(command):
    """Execute a shell command and return its output"""
    try:
        output = subprocess.check_output(command, shell=True, text=True, stderr=subprocess.PIPE)
        return output
    except subprocess.CalledProcessError as e:
        return f"Error executing {command}: {e.stderr}"

def write_to_log(text, color=None):
    """Write text to both console and log file"""
    if color:
        print(f"{color}{text}{Colors.NC}")
    else:
        print(text)
    
    with open(LOG_FILE, 'a') as log:
        log.write(text + '\n')

def main():
    # Check if running as root
    if os.geteuid() != 0:
        print("This script must be run as root")
        exit(1)

    # Create log directory if it doesn't exist
    Path(LOG_DIR).mkdir(parents=True, exist_ok=True)

    # Start logging
    write_to_log("=== Security Audit Report ===")
    write_to_log(f"Date: {timestamp}")
    write_to_log("")

    # Security checks
    checks = [
        {
            "title": "Currently Connected Users",
            "command": "who"
        },
        {
            "title": "Recent Successful Logins",
            "command": "last | head -n 5"
        },
        {
            "title": "Failed SSH Login Attempts",
            "command": "journalctl | grep 'Failed password' | tail -n 5"
        },
        {
            "title": "Login Attempts from Unusual IPs",
            "command": "journalctl | grep 'sshd' | grep 'Failed password' | awk '{print $11}' | sort | uniq -c | sort -nr"
        },
        {
            "title": "Recent SSH Authentication Logs",
            "command": "journalctl -u ssh.service --no-pager | tail -n 10"
        },
        {
            "title": "Recent Authorization Failures",
            "command": "journalctl | grep 'authentication failure' | tail -n 5"
        },
        {
            "title": "Failed sudo Attempts",
            "command": "journalctl | grep 'sudo.*FAILED' | tail -n 5"
        },
        {
            "title": "Users with Root Privileges",
            "command": "grep ':0:' /etc/passwd"
        },
        {
            "title": "Recent Password Changes",
            "command": "journalctl | grep 'password changed' | tail -n 5"
        },
        {
            "title": "Recently Modified System Files",
            "command": "find /etc -mtime -1 -type f -ls"
        },
        {
            "title": "Files with No User/Group",
            "command": "find / -nouser -o -nogroup 2>/dev/null"
        },
        {
            "title": "Recent System Boot Logs",
            "command": r"journalctl --boot=0 | grep -i 'boot\|started\|failed' | tail -n 10"
        },
        {
            "title": "Failed Services",
            "command": "systemctl --failed"
        },
        {
            "title": "Currently Listening Ports",
            "command": "ss -tuln | grep LISTEN"
        }
    ]

    #Run all checks
    for check in checks:
        write_to_log(f"\n{check['title']}:", Colors.GREEN)
        result = run_command(check['command'])
        write_to_log(result)
        
    # Complete
    write_to_log("\n=== Security Check Complete ===", Colors.YELLOW)
    write_to_log(f"Log saved to: {LOG_FILE}")

    # Set appropriate permissions
    os.chmod(LOG_FILE, 0o600)

if __name__ == "__main__":
    main()