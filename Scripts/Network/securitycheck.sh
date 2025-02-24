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
LOG_FILE="/home/log/security_check_$(format_date).log"

# check log directyory exists
mkdir -p "$(dirname "$LOG_FILE")"

{
# Write to log with time stamp
echo "${YELLOW}=== Security Audit Report ===${NC}" | tee "$LOG_FILE"
echo "Date: $(format_date)"
echo ""

# Check Currently Connected Users
echo -e "${GREEN}Currently Connected Users:${NC}"
who
echo -e ""

# Check Successful Logins
echo -e "${GREEN}Recent Successful Logins:${NC}"
last | head -n 5
echo -e ""

# Check Failed SSH Login Attempts
echo -e "${GREEN}Failed SSH Login Attempts:${NC}"
journalctl | grep "Failed password" | tail -n 5
echo -e ""

# Check for Login Attempts from Unusual IPs
echo -e "${GREEN}Login Attempts from Unusual IPs:${NC}"
journalctl | grep "sshd" | grep "Failed password" | awk '{print $11}' | sort | uniq -c | sort -nr
echo -e ""

# Check SSH Authentication Logs
echo -e "${GREEN}Recent SSH Authentication Logs:${NC}"
journalctl -u ssh.service --no-pager | tail -n 10
echo -e ""

# Check Authorization Failures
echo -e "${GREEN}Recent Authorization Failures:${NC}"
journalctl | grep "authentication failure" | tail -n 5
echo -e ""

# Check Failed sudo Attempts
echo -e "${GREEN}Failed sudo Attempts:${NC}"
journalctl | grep "sudo.*FAILED" | tail -n 5
echo -e ""

# Check for Users with UID 0 (root privileges)
echo -e "${GREEN}Users with Root Privileges:${NC}"
grep ":0:" /etc/passwd
echo -e ""

# Check Last Password Changes
echo -e "${GREEN}Recent Password Changes:${NC}"
journalctl | grep "password changed" | tail -n 5
echo -e ""

# Check for Modified System Files
echo -e "${GREEN}Recently Modified System Files:${NC}"
find /etc -mtime -1 -type f -ls
echo -e ""

# Check for Files with No User/Group
echo -e "${GREEN}Files with No User/Group:${NC}"
find / -nouser -o -nogroup 2>/dev/null 
echo -e ""

# Check System Boot Logs
echo -e "${GREEN}Recent System Boot Logs:${NC}"
journalctl --boot=0 | grep -i "boot\|started\|failed" | tail -n 10
echo -e ""

# Check for Failed Services
echo -e "${GREEN}Failed Services:${NC}"
systemctl --failed
echo -e ""

# Check Listening Ports
echo -e "${GREEN}Currently Listening Ports:${NC}"
ss -tuln | grep LISTEN
echo -e ""

echo -e "${YELLOW}=== Security Check Complete ===${NC}"
echo "Log saved to: $LOG_FILE"
} |tee "$LOG_FILE"
# Set appropriate permissions
chmod 600 "$LOG_FILE"
