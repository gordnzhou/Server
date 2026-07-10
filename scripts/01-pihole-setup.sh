#!/bin/bash
set -e

# ---- EDIT THESE BEFORE RUNNING ----
TIMEZONE="TIMEZONE_HERE"
PIHOLE_PASSWORD="PASSSWORD_HERE"
# ------------------------------------

echo ">>> Freeing up port 53 for Pi-hole..."
sudo sed -i 's/#DNSStubListener=yes/DNSStubListener=no/' /etc/systemd/resolved.conf
sudo systemctl restart systemd-resolved

echo ">>> Starting Pi-hole container..."
mkdir -p ~/pihole/etc-pihole ~/pihole/etc-dnsmasq.d

sudo docker run -d \
  --name pihole \
  --network host \
  -p 53:53/tcp -p 53:53/udp \
  -p 80:80 \
  -e TZ="$TIMEZONE" \
  -e FTLCONF_webserver_api_password="$PIHOLE_PASSWORD" \
  -v ~/pihole/etc-pihole:/etc/pihole \
  -v ~/pihole/etc-dnsmasq.d:/etc/dnsmasq.d \
  --cap-add NET_ADMIN \
  --restart unless-stopped \
  pihole/pihole:latest

echo ">>> Done. Pi-hole admin will be at http://$(hostname -I | awk '{print $1}')/admin"
echo ">>> Log out and back in for docker group permissions to apply."
