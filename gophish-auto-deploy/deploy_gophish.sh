#!/bin/bash
# ==========================================
# GoPhish Automated Deployment Script
# Interactive version (asks variables at run)
# ==========================================

set -e

# -------- ROOT CHECK --------
if [[ $EUID -ne 0 ]]; then
  echo "[!] Please run as root"
  exit 1
fi

echo "=== GoPhish Auto Deployment ==="

# -------- ASK VARIABLES --------
read -rp "Enter domain name (e.g. example.com): " DOMAIN
read -rp "Enter GoPhish version (default: 0.12.1): " GOPHISH_VERSION

# Defaults
GOPHISH_VERSION=${GOPHISH_VERSION:-0.12.1}

INSTALL_DIR="/opt/gophish"
GOPHISH_ZIP="gophish-v${GOPHISH_VERSION}-linux-64bit.zip"
GOPHISH_URL="https://github.com/gophish/gophish/releases/download/v${GOPHISH_VERSION}/${GOPHISH_ZIP}"

CERT_PATH="/etc/letsencrypt/live/${DOMAIN}/fullchain.pem"
KEY_PATH="/etc/letsencrypt/live/${DOMAIN}/privkey.pem"

echo "[i] Domain        : $DOMAIN"
echo "[i] GoPhish ver   : $GOPHISH_VERSION"
echo "[i] Install dir  : $INSTALL_DIR"
echo ""

# -------- SYSTEM UPDATE --------
echo "[+] Updating system..."
apt update -y && apt upgrade -y

# -------- INSTALL DEPENDENCIES --------
echo "[+] Installing dependencies..."
apt install -y unzip certbot curl jq

# -------- DOWNLOAD GOPHISH --------
echo "[+] Downloading GoPhish..."
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

if [[ ! -f gophish ]]; then
  wget -q "$GOPHISH_URL"
  unzip -o "$GOPHISH_ZIP"
  chmod +x gophish
fi

# -------- CERTBOT DNS CHALLENGE --------
echo "[+] Starting Certbot DNS challenge"
echo "[!] Add TXT record when prompted (_acme-challenge)"
echo "[!] After DNS propagation, press ENTER"

certbot certonly \
  -d "$DOMAIN" \
  --manual \
  --preferred-challenges dns \
  --register-unsafely-without-email

# -------- VERIFY CERT --------
if [[ ! -f "$CERT_PATH" || ! -f "$KEY_PATH" ]]; then
  echo "[!] Certificate files not found. Exiting."
  exit 1
fi

echo "[✓] Certificate found"

# -------- CONFIGURE GOPHISH --------
echo "[+] Updating config.json..."

jq \
  --arg cert "$CERT_PATH" \
  --arg key "$KEY_PATH" \
  '.
  | .admin_server.listen_url = "0.0.0.0:3333"
  | .admin_server.use_tls = true
  | .admin_server.cert_path = $cert
  | .admin_server.key_path = $key
  | .phish_server.listen_url = "0.0.0.0:80"
  | .phish_server.use_tls = false
  ' config.json > config.tmp && mv config.tmp config.json

# -------- STOP OLD GOPHISH --------
pkill gophish 2>/dev/null || true

# -------- START GOPHISH --------
echo "[+] Launching GoPhish..."
nohup ./gophish > gophish.log 2>&1 &

sleep 3

# -------- VERIFY --------
if ss -tulnp | grep -q 3333; then
  echo "[✓] GoPhish running"
  echo "[✓] Admin URL: https://${DOMAIN}:3333"
  echo "[i] Admin credentials in: $INSTALL_DIR/gophish.log"
else
  echo "[!] GoPhish failed to start"
  exit 1
fi

echo "[✓] Deployment completed successfully"
