#!/bin/bash

# Colors for Terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
# No Color
NC='\033[0m' 

#root check
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root"
    exit 1
fi

#format date
format_date() {
    date "+%d-%m-%Y_%H:%M:%S"
}

# Log file path
LOG_FILE="/home/log/network_scan_$(format_date).log"

# check log directyory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Define the target IP address or hostname
TARGET="127.0.0.1"

# Write to log with time stamp
echo -e "${YELLOW}=== Network Scan Report ===${NC}" | tee "$LOG_FILE"
# echo -e "Date: $(format_date)" | tee -a "$LOG_FILE"
echo -e "" | tee -a "$LOG_FILE" 
echo -e "${GREEN}=== Full Port Scan with Service Detection ===${NC}" | tee -a "$LOG_FILE"
nmap -p- -sV -sC -A -T4 $TARGET | tee -a "$LOG_FILE"
echo -e "" | tee -a "$LOG_FILE"
echo -e "${GREEN}=== Additional UDP Scan ===${NC}" | tee "$LOG_FILE"
nmap -sU -T4 $TARGET | tee -a "$LOG_FILE"
echo -e "" | tee -a "$LOG_FILE"

echo -e "${YELLOW}=== Network Scan Complete ===${NC}" | tee -a "$LOG_FILE"
echo "Log saved to: $LOG_FILE" | tee -a "$LOG_FILE"

# Set appropriate permissions
chmod 600 "$LOG_FILE"
