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
LOG_FILE="/var/log/security/network_scan.sh_$(format_date).log"

# check log directyory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Define the target IP address or hostname
TARGET="127.0.0.1"
{
# Write to log with time stamp
echo -e "${YELLOW}=== Network Scan Report ===${NC}"
echo -e ""  
echo -e "${GREEN}=== Full Port Scan with Service Detection ===${NC}" 
nmap -p- -sV -sC -A -T4 $TARGET 
echo -e "" 
echo -e "${GREEN}=== Additional UDP Scan ===${NC}"
nmap -sU -T4 $TARGET 
echo -e "" 
echo -e "${YELLOW}=== Network Scan Complete ===${NC}" 
echo "Log saved to: $LOG_FILE" 
} | tee -a "$LOG_FILE"

# Set appropriate permissions
chmod 600 "$LOG_FILE"