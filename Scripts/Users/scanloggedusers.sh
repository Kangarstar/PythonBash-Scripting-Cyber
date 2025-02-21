#!/bin/bash

#Log file path
LOG_FILE="/workspace/logs/loggeduserssh.log"

#root check
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root"
    exit 1
fi

#format date
format_date() {
    date "+%d-%m-%Y %H:%M:%S"
}

#check log directyory exists
mkdir -p "$(dirname "$LOG_FILE")"

# prompt
echo "----------------------------------------"
echo "Checking login status for all users..."
echo "----------------------------------------"

#logs
echo "=========================================" >> "$LOG_FILE"
echo "====   Useless users status check    ====" >> "$LOG_FILE"
echo "=========================================" >> "$LOG_FILE"



#regular users count
user_count=0

# Process all users
while IFS=: read -r username password uid gid gecos home shell; do
    # Skip system users and nologin/false shells
    if [ "$uid" -ge 1000 ] 2>/dev/null && \
       [ "$shell" != "/usr/sbin/nologin" ] && \
       [ "$shell" != "/bin/false" ]; then

        ((user_count++))

        # Display on screen
        echo "Found User: $username (UID: $uid)"

        # Write to log
        {
            echo "User: $username"
            echo "UID: $uid"
            echo "Home Directory: $home"
            echo "Shell: $shell"
            echo "Status: $(who | grep -c "^$username ")"
            # echo "----------------------------------------"
        } >> "$LOG_FILE"
    fi
done < /etc/passwd

# Prompt summary
# echo -e "\nSummary:"
echo "----------------------------------------"
echo "Total users who have logged in: $user_count"
echo "Check completed at: $(format_date)"
echo "Log file created at: $LOG_FILE"
echo "----------------------------------------"

# Write summary to log
{
    echo "----------------------------------------" 
    echo "Total users who have logged in: $user_count"
    echo "----------------------------------------" 
    echo "Check completed at: $(format_date)"
    echo "========================================"
    echo "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv" 
} >> "$LOG_FILE"

# Set appropriate permissions
chmod 600 "$LOG_FILE"

exit 0