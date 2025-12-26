# GoPhish Auto Deploy

This project provides a Bash script to automate the deployment of GoPhish on an Ubuntu server.  
It installs required dependencies, configures HTTPS using Certbot (DNS challenge), updates the GoPhish configuration, and launches the admin interface.

---

## Overview

The script automates the following tasks:

- Updates the system
- Installs required packages
- Downloads and sets up GoPhish
- Generates an SSL certificate using Certbot (DNS-based validation)
- Automatically updates `config.json`
- Launches GoPhish securely
- Logs initial admin credentials

---

## Requirements

- Ubuntu server
- Root or sudo access
- A registered domain name
- Ability to add DNS TXT records
- Open ports:
  - `3333` – GoPhish Admin Interface
  - `80` – Phishing Server

---

## Usage

Clone the repository and run the script:

```bash
git clone https://github.com/<your-username>/gophish-auto-deploy.git
cd gophish-auto-deploy
chmod +x deploy_gophish.sh
sudo ./deploy_gophish.sh

During Execution

The script will prompt for:

Domain name

DNS TXT record (_acme-challenge) required by Certbot

After adding the DNS TXT record and allowing DNS propagation, press Enter to continue.

Accessing GoPhish
Admin Interface
https://your-domain:3333

Login Details

Username

admin


Temporary Password

/opt/gophish/gophish.log


You will be required to set a new password on first login.

Notes

DNS TXT record creation is manual

Certbot rate limits apply

Intended for learning, labs, and authorized testing only

Author

Razzle Mouse
Cybersecurity | Red Team | Automation

Disclaimer

This project is for educational and authorized security testing purposes only.
Any misuse of this tool is strictly prohibited.
