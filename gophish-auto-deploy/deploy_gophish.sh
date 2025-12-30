#!/usr/bin/env python3

import os
import subprocess
import json
import argparse
import requests

# =========================
# Constants
# =========================
GOPHISH_VERSION = "v0.12.1"
GOPHISH_DIR = "/opt/gophish"
LOG_FILE = f"{GOPHISH_DIR}/gophish.log"

# =========================
# Helper Functions
# =========================
def run_command(cmd, check=True):
    print(f"[+] Running: {cmd}")
    result = subprocess.run(
        cmd,
        shell=True,
        check=check,
        capture_output=True,
        text=True
    )
    if result.stdout:
        print(result.stdout)
    if result.stderr:
        print(result.stderr)
    return result.stdout.strip()


# =========================
# System Setup (DigitalOcean)
# =========================
def update_system():
    run_command("apt update -y")
    run_command("apt upgrade -y")
    run_command("apt install -y unzip wget certbot")


# =========================
# GoPhish Setup
# =========================
def setup_gophish():
    os.makedirs(GOPHISH_DIR, exist_ok=True)
    os.chdir(GOPHISH_DIR)

    zip_url = f"https://github.com/gophish/gophish/releases/download/{GOPHISH_VERSION}/gophish-{GOPHISH_VERSION}-linux-64bit.zip"

    run_command(f"wget -q {zip_url}")
    run_command(f"unzip -o gophish-{GOPHISH_VERSION}-linux-64bit.zip")
    run_command("chmod +x gophish")


# =========================
# SSL (Manual DNS – safest)
# =========================
def request_ssl_certificate(domain):
    print("\n[!] Manual DNS challenge will start")
    print("[!] Add TXT record when prompted\n")

    run_command(
        f"certbot certonly "
        f"--manual "
        f"--preferred-challenges dns "
        f"-d {domain} "
        f"--register-unsafely-without-email "
        f"--agree-tos"
    )


# =========================
# GoPhish config.json edit
# =========================
def modify_config(domain):
    config_path = f"{GOPHISH_DIR}/config.json"

    cert_path = f"/etc/letsencrypt/live/{domain}/fullchain.pem"
    key_path = f"/etc/letsencrypt/live/{domain}/privkey.pem"

    with open(config_path, "r") as f:
        config = json.load(f)

    config["admin_server"]["listen_url"] = "0.0.0.0:3333"
    config["admin_server"]["use_tls"] = True
    config["admin_server"]["cert_path"] = cert_path
    config["admin_server"]["key_path"] = key_path

    with open(config_path, "w") as f:
        json.dump(config, f, indent=4)

    print("[+] config.json updated with SSL paths")


# =========================
# Start GoPhish
# =========================
def start_gophish():
    os.chdir(GOPHISH_DIR)
    print("[+] Starting GoPhish")

    with open(LOG_FILE, "w") as log:
        subprocess.Popen(
            ["./gophish"],
            stdout=log,
            stderr=log
        )


# =========================
# Namecheap DNS Automation
# =========================
def create_namecheap_txt(domain, host, value, api_user, api_key, client_ip):
    sld, tld = domain.split(".", 1)

    url = "https://api.namecheap.com/xml.response"
    payload = {
        "ApiUser": api_user,
        "ApiKey": api_key,
        "UserName": api_user,
        "ClientIp": client_ip,
        "Command": "namecheap.domains.dns.setHosts",
        "SLD": sld,
        "TLD": tld,
        "HostName1": host,
        "RecordType1": "TXT",
        "Address1": value,
        "TTL1": 60,
    }

    print("[+] Sending request to Namecheap API")
    r = requests.post(url, data=payload)
    print(r.text)


# =========================
# Main
# =========================
def main():
    parser = argparse.ArgumentParser(
        description="GoPhish Auto Deploy (DigitalOcean + Namecheap)"
    )

    parser.add_argument("-d", "--domain", required=True, help="example.com")
    parser.add_argument("--nc-user", help="Namecheap API Username")
    parser.add_argument("--nc-key", help="Namecheap API Key")
    parser.add_argument("--client-ip", help="Public IP of your DO droplet")

    args = parser.parse_args()

    domain = args.domain
    nc_user = args.nc_user or os.getenv("NAMECHEAP_API_USER")
    nc_key = args.nc_key or os.getenv("NAMECHEAP_API_KEY")
    client_ip = args.client_ip or os.getenv("PUBLIC_IP")

    print(f"\n🚀 Deploying GoPhish on DigitalOcean")
    print(f"🌐 Domain: {domain}\n")

    update_system()
    setup_gophish()
    request_ssl_certificate(domain)
    modify_config(domain)
    start_gophish()

    print("\n✅ Deployment Complete")
    print(f"🔐 Admin Panel: https://{domain}:3333")
    print(f"📄 Logs: {LOG_FILE}")

    if nc_user and nc_key:
        print("\nℹ️ Namecheap credentials detected (DNS automation ready)")
    else:
        print("\nℹ️ Namecheap API not provided – DNS automation skipped")


if __name__ == "__main__":
    main()
