#!/bin/bash

# root check
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root"
    exit 1
fi

ROCKYOU_DIR="/home/wordlists"
FILE="$ROCKYOU_DIR/rockyou.txt"
URL="https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt"

mkdir -p "$(dirname "$ROCKYOU_DIR")"

##############################
#      Creating new User     #
##############################

# Name of the user to create
read -p "Enter username to create : " username

# Check empty username or already exist
if id "$username" &>/dev/null || [[ ${#username} == 0 ]]; then
    echo "Caution : Username can't be empty or already exists."
    exit 1
else
    # Select password
    read -p "Enter your password: " password
    echo ""

    # Checking password
    # Check if password is empty or at least 12 characters long
    if [[ ${#password} == 0 || ! ${#password} -ge 12 ]]; then
        echo "Password can't be empty, must contain at least 12 characters long, with uppercase and lower characters, a number and special character."
        exit 1

    # Check for uppercase and lowercase letters
    elif ! [[ "$password" =~ [a-z] && "$password" =~ [A-Z] ]]; then
        echo "Weak: Password must contain both uppercase and lowercase letters"
        exit 1

    else
        # Check for at least one special character and at least a numeric character
        if [[ ! "$password" =~ [^a-zA-Z0-9] || ! "$password" =~ [0-9] ]]; then
            echo "Weak: Password must contain a number and at least one special character ¨£$¤²%µ*<>?,.;:/§!&~\"#'{([-+|_\^@=])}\`"
            exit 1
        fi
    fi

    # If all conditions match then confirm the password
    echo "Your password passes security requirements."
    read -p "Please confirm the password : " password1
    if [[ $password != $password1 ]]; then
        echo "The passwords entered are not the same. Please retry."
        exit 1
    fi
fi

# Check if the file rockyou.txt is already downloaded
if [ ! -f "$FILE" ]; then
    echo "$FILE not found. Downloading..."
    curl -s -L -o "$FILE" "$URL" && echo "Download complete." || echo "Download failed!"
fi

# Clean the password: remove non-alphanumeric characters
cleaned_password=$(echo "$password" | tr -cd '[:alnum:]')
echo "Cleaned password: $cleaned_password"

# Search for the cleaned password in rockyou.txt
echo "Searching for match in rockyou.txt..."

# Premier grep : Recherche exacte du mot de passe nettoyé
if grep -q -i "^$cleaned_password$" "$FILE" 2>/dev/null; then
    LINE_NUMBER=$(grep -n -i "^$cleaned_password$" "$FILE" | cut -d: -f1)
    echo "WARNING: Cleaned password found in RockYou list at line $LINE_NUMBER"
    echo "This password is considered compromised and should not be used!"
else
    # Deuxième grep : Recherche d'une correspondance partielle avec le mot de passe nettoyé
    if grep -q -i "$cleaned_password" "$FILE" 2>/dev/null; then
        echo "WARNING: A similar password found in RockYou list!"
        echo "A password similar to yours was found, it may still be compromised."
    else
        echo "Password not found in RockYou list."
        echo "Note: This doesn't guarantee the password is secure, just that it's not in this specific list."

    # Ajout de l'utilisateur
    # Créer l'utilisateur avec un répertoire home par défaut
        sudo useradd -m "$username"

# Définir le mot de passe pour l'utilisateur
        echo "$username:$password" | sudo chpasswd

# Afficher un message de confirmation
        echo "L'utilisateur '$username' a été créé avec succès."

    fi
fi