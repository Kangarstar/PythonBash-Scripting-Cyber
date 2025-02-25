#!/usr/bin/env python3

import os
import subprocess
import datetime
from pathlib import Path

# Define the target IP address or hostname
TARGET="127.0.0.1"

# Colors for terminal output
class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    NC = '\033[0m'  # No Color

# Log file path
LOG_DIR = "/home/log"
timestamp = datetime.datetime.now().strftime("%d-%m-%Y_%H:%M:%S")
LOG_FILE = f"{LOG_DIR}/network_scan.py_{timestamp}.log"

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
    write_to_log("=== Netwok Scan Report ===")
    write_to_log(f"Date: {timestamp}")
    write_to_log("")

    # Network scan
    scans = [
        {
            "title" : "Full Port Scan with Service Detection",
            "command" : f"nmap -p- -sV -sC -A -T4 {TARGET}"
        },
        {
            "title" : "Additional UDP Scan",
            "command" : f"nmap -sU -T4 {TARGET}"
        }
        
    ]
    
    # Run all checks
    for scan in scans:
        write_to_log(f"\n{scan['title']}:", Colors.GREEN)
        result = run_command(scan['command'])
        write_to_log(result)

    # Complete
    write_to_log("\n=== Network Scan Complete ===", Colors.YELLOW)
    write_to_log(f"Log saved to: {LOG_FILE}")

    # Set appropriate permissions
    os.chmod(LOG_FILE, 0o600)

if __name__ == "__main__":
    main()