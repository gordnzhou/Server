#!/bin/bash

sudo ufw --force reset

sudo ufw default deny incoming
sudo ufw default allow outgoing

# allow only SSH, HTTP/HTTPS
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# for pi-hole
sudo ufw allow from 192.168.1.0/24 to any port 8081 proto tcp
sudo ufw allow from 192.168.1.0/24 to any port 53 proto udp
sudo ufw allow from 192.168.1.0/24 to any port 53 proto tcp

sudo ufw --force enable

sudo ufw status verbose
