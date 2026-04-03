##
DigiTP7-Scripting-Cyber

This project is dedicated to enhancing Linux system security. It provides a comprehensive suite of Bash and Python scripts designed to detect and remediate network, system, and user-level vulnerabilities.
Motivation

The core objective of this project was to explore the functional differences between Bash and Python scripting. By implementing the same security tools in both languages, we can compare:

    Syntax complexity and readability.

    Language-specific quirks and library dependencies.

    Execution performance and resource overhead.

Features

The project is organized into four critical security categories:

    Network: Scans for open ports and identifies potentially vulnerable services exposed on the network.

    Security: Performs comprehensive audits, monitoring active connections, intrusion attempts, and service failures.

    Users: Scans for redundant or unauthorized user accounts to streamline server access management.

    Password: Facilitates secure user creation with passwords that meet strict regulatory standards (CNIL) and are cross-referenced against compromised password lists.

Project Structure
Plaintext

DigiTP7-Scripting-Cyber
└── scripts/
    ├── network/
    │   ├── networkscan.sh
    │   └── networkscan.py
    ├── system/
    │   ├── securityaudit.sh
    │   └── securityaudit.py
    ├── users/
    │   ├── usercheck.sh
    │   └── usercheck.py
    ├── password/
    │   ├── addusersecure.sh
    │   └── addusersecure.py
    └── crontab

Quick Start

To set up the security suite on your local machine, run the following commands:
1. Install Dependencies
Bash

sudo apt update && sudo apt install -y git curl nmap python3 python3-requests

2. Clone the Repository
Bash

sudo git clone git@github.com:Kangarstar/DigiTP7-Scripting-Cyber.git /etc/scripts

3. Set Permissions & Automation
Bash

# Secure the directory
sudo chmod -R 700 /etc/scripts

# Install the crontab for scheduled execution
crontab /etc/scripts/crontab

Usage
Manual Execution

You can run any script manually using sudo. For example:

To run a Bash audit:
Bash

sudo /etc/scripts/system/securityaudit.sh

To run a Python network scan:
Bash

sudo python3 /etc/scripts/network/networkscan.py

Logs

All execution results and security findings are logged in the following directory:
 /var/log/security/
Contributing

We welcome contributions! Please follow these steps to help improve the project:

    Clone the Repo
    Bash

    git clone https://github.com/Kangarstar/DigiTP7-Scripting-Cyber.git
    cd DigiTP7-Scripting-Cyber

    Build (If applicable)
    Bash

    go build

    Run Tests
    Bash

    go test ./...

    Submit a Pull Request
    Fork the repository and open a pull request to the main branch.
