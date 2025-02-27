# DigiTP7-Scripting-Cyber

## Présentation du projet

Ce projet est dédié à l'amélioration de la sécurité des systèmes Linux. Il propose un ensemble de scripts en Bash et Python pour détecter et corriger les vulnérabilités réseau, système et utilisateurs.

## Fonctionnalités principales

Le projet se compose de quatre catégories de scripts :

- **Network** : Ces scripts scannent les ports ouverts et identifient les services potentiellement vulnérables sur le réseau.
- **Sécurité** : Ils réalisent un audit de sécurité complet, vérifiant les connexions, les tentatives d'intrusion et les services défaillants.
- **Users** : Ces scripts vérifient la présence d'utilisateurs superflus sur le serveur, améliorant ainsi la gestion des comptes.
- **Password** : Ils permettent de créer des utilisateurs avec des mots de passe sécurisés, conformes aux recommandations de la CNIL et absents des listes de mots de passe compromis.

## Structure du projet
```
DigiTP7-Scripting-Cyber
└── scripts/
    ├── network/
    │   ├── networkscan.sh
    │   └── networkscan.py
    ├── security/
    │   ├── securityaudit.sh
    │   └── securityaudit.py
    ├── users/
    │   ├── usercheck.sh
    │   └── usercheck.py
    ├── password/
    │   ├── addusersecure.sh
    │   └── addusersecure.py
    └── crontab
```

## Installation

Pour installer et configurer le projet, suivez les étapes ci-dessous :

```bash

# Installation des dépendances
sudo apt update && sudo apt install -y git curl nmap

# Clonage du dépôt
sudo git clone git@github.com:Kangarstar/DigiTP7-Scripting-Cyber.git /etc/scripts

# Attribution des permissions
sudo chmod -R 700 /etc/scripts

# Installation du crontab pour l'exécution automatique
crontab /etc/scripts/crontab

```
## Execution manuelle d'un script
```bash
sudo /etc/scripts/security/securityaudit.sh
# ou
sudo /etc/scripts/scripts/network/networkscan.py
```

**Tous les logs sont enregistrés dans le répertoire `/var/log/security/`.**