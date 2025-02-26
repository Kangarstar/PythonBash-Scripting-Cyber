#!/bin/bash

# Colors for Terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Format date function
format_date() {
    date "+%d-%m-%Y_%H:%M:%S"
}

# Log file path
LOG_FILE="/var/log/security/adduser_secure_$(format_date).log"

# root check
if [ "$(id -u)" != "0" ]; then
    echo -e "${RED}This script must be run as root${NC}"
    exit 1
fi

# Create log directory if it doesn't exist
mkdir -p "$(dirname "$LOG_FILE")"

ROCKYOU_DIR="/etc/scripts/wordlists"
FILE="$ROCKYOU_DIR/rockyou.txt"
URL="https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt"

# Create directory if it doesn't exist
mkdir -p "$ROCKYOU_DIR"

# Only log who executed the script initially
echo "[$(format_date)] Script executed by $(whoami)" > "$LOG_FILE"

##############################
#      Creating new User     #
##############################

# Name of the user to create - keep the prompt on the same line
echo -ne "${YELLOW}Enter username to create : ${NC}"
read username

# Check empty username or already exist
if id "$username" &>/dev/null || [[ ${#username} == 0 ]]; then
    echo -e "${RED}Caution : Username can't be empty or already exists.${NC}"
    # Log failed attempt
    echo "[$(format_date)] Failed to create user: '$username' - empty or already exists" >> "$LOG_FILE"
    exit 1
else
    # Select password - make it visible when typing
    echo -ne "${YELLOW}Enter your password: ${NC}"
    read password

    # Checking password
    # Check if password is empty or at least 12 characters long
    if [[ ${#password} == 0 || ! ${#password} -ge 12 ]]; then
        echo -e "${RED}Password can't be empty, must contain at least 12 characters long, with uppercase and lower characters, a number and special character.${NC}"
        exit 1

    # Check for uppercase and lowercase letters
    elif ! [[ "$password" =~ [a-z] && "$password" =~ [A-Z] ]]; then
        echo -e "${RED}Weak: Password must contain both uppercase and lowercase letters${NC}"
        exit 1

    else
        # Check for at least one special character and at least a numeric character
        if [[ ! "$password" =~ [^a-zA-Z0-9] || ! "$password" =~ [0-9] ]]; then
            echo -e "${RED}Weak: Password must contain a number and at least one special character ¨£$¤²%µ*<>?,.;:/§!&~\"#'{([-+|_\^@=])}\`${NC}"
            exit 1
        fi
    fi

    # If all conditions match then confirm the password
    echo -e "${GREEN}Your password passes security requirements.${NC}"
    echo -ne "${YELLOW}Please confirm the password : ${NC}"
    read password1

    if [[ $password != $password1 ]]; then
        echo -e "${RED}The passwords entered are not the same. Please retry.${NC}"
        exit 1
    fi
fi

# Check if the file rockyou.txt is already downloaded
if [ ! -f "$FILE" ]; then
    echo -e "${YELLOW}$FILE not found. Downloading...${NC}"
    curl -s -L -o "$FILE" "$URL" 
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Download complete.${NC}"
    else
        echo -e "${RED}Download failed! Exiting.${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}Using existing rockyou.txt wordlist${NC}"
fi

# Clean the password: remove non-alphanumeric characters
cleaned_password=$(echo "$password" | tr -cd '[:alnum:]')

# Search for the cleaned password in rockyou.txt
echo -e "${YELLOW}Searching for match in rockyou.txt...${NC}"

# Premier grep : Recherche exacte du mot de passe nettoyé
if grep -q -i "^$cleaned_password$" "$FILE" 2>/dev/null; then
    LINE_NUMBER=$(grep -n -i "^$cleaned_password$" "$FILE" | cut -d: -f1)
    echo -e "${RED}WARNING: Cleaned password found in RockYou list at line $LINE_NUMBER${NC}"
    echo -e "${RED}This password is considered compromised and should not be used!${NC}"
    # Log password check failure
    echo "[$(format_date)] Password check failed for user '$username' - found in rockyou.txt" >> "$LOG_FILE"
    exit 1
else
    # Deuxième grep : Recherche d'une correspondance partielle avec le mot de passe nettoyé
    if grep -q -i "$cleaned_password" "$FILE" 2>/dev/null; then
        echo -e "${YELLOW}WARNING: A similar password found in RockYou list!${NC}"
        echo -e "${YELLOW}A password similar to yours was found, it may still be compromised.${NC}"
        # Log similar password warning
        echo "[$(format_date)] Password check warning for user '$username' - similar password found" >> "$LOG_FILE"
        exit 1
    else
        echo -e "${GREEN}Password not found in RockYou list.${NC}"
        echo -e "${YELLOW}Note: This doesn't guarantee the password is secure, just that it's not in this specific list.${NC}"

        # Ajout de l'utilisateur
        # Créer l'utilisateur avec un répertoire home par défaut
        echo -e "${YELLOW}Creating user account...${NC}"
        sudo useradd -m "$username"

        # Définir le mot de passe pour l'utilisateur
        echo "$username:$password" | sudo chpasswd

        # Afficher un message de confirmation
        echo -e "${GREEN}The user '$username' was successfully created.${NC}"
        
        # Log successful user creation (only username, no details)
        echo "[$(format_date)] User '$username' created successfully by $(whoami)" >> "$LOG_FILE"
    fi
fi

echo -e "${GREEN}Script completed successfully${NC}"
echo -e "${YELLOW}Log saved to: $LOG_FILE${NC}"

# Set appropriate permissions for the log file
chmod 600 "$LOG_FILE"