GoPhish Auto Deploy

A simple Bash script to automatically deploy GoPhish on an Ubuntu server with HTTPS enabled using Certbot (DNS challenge).

✨ What This Script Does

Updates the system

Installs required packages

Downloads and sets up GoPhish

Generates SSL certificate (Certbot DNS challenge)

Updates config.json automatically

Launches GoPhish securely

Logs admin credentials

🛠️ Requirements

Ubuntu server

Root / sudo access

A domain name

Ability to add DNS TXT records

Open ports: 3333, 80

🚀 How to Use
git clone https://github.com/<your-username>/gophish-auto-deploy.git
cd gophish-auto-deploy
chmod +x deploy_gophish.sh
sudo ./deploy_gophish.sh


👉 Enter domain name when prompted
👉 Add _acme-challenge TXT record
👉 Press Enter to continue

🔐 Access GoPhish

URL

https://your-domain:3333


Username: admin

Password: Check

/opt/gophish/gophish.log

⚠️ Notes

DNS TXT record is manual

Certbot rate limits apply

For learning / lab use only

👤 Author

Razzle Mouse
Cybersecurity | Red Team | Automation

⚠️ Disclaimer

For educational and authorized security testing only.
