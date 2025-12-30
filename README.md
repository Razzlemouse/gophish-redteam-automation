# GoPhish Automated Deployment (DigitalOcean + Namecheap)

This repository contains a Python script to automate the deployment of **GoPhish** on an Ubuntu server (DigitalOcean tested), including:

- GoPhish installation
- SSL certificate setup using Certbot (manual DNS challenge)
- Automatic `config.json` configuration
- Optional Namecheap DNS automation

## ⚠️ Disclaimer
This tool is intended **only for authorized security testing, labs, and training**.
Do NOT use this against systems or users without explicit permission.

## Requirements
- Ubuntu 20.04 / 22.04
- Python 3.8+
- Root or sudo access
- A domain name
- (Optional) Namecheap API access

## Usage

### Using environment variables (recommended)
```bash
export NAMECHEAP_API_USER="youruser"
export NAMECHEAP_API_KEY="yourapikey"
export PUBLIC_IP="your.droplet.ip"

sudo python3 deploy_gophish.py -d example.com

or

### Using command-line arguments

sudo python3 deploy_gophish.py \
  -d example.com \
  --nc-user NAMECHEAPUSER \
  --nc-key NAMECHEAPAPIKEY \
  --client-ip YOUR_DO_PUBLIC_IP
