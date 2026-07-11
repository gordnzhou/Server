# Server Setup


## Initial Setup 

### Requirements
- Machine running Linux connected to the internet

### Steps
1. install docker onto machines
1. do `mkdir services`. Add `docker-compose.yml` and `nginx/nginx.conf` to `services/`
1. clone website repo into `services/` and configure `docker-compose.yml`
1. (optional) install node, npm to test website containerless

## Deploying to the Internet

### Prereqs:
- A domain from a domain registrar that routes to home router's public IP / your desired IP

### Steps
1. Add firewall rules
1. On router, Enable port forwarding for ports 80 and 443 to the server machine
    - Verify that ports are [open](https://www.yougetsignal.com/tools/open-ports/)
    - **All** inbound requests from port 80 and 443 will route through Nginx first
1. Edit `nginx/nginx.conf` to route `/.well-known/acme-challenge` to `/var/www/certbot` and run `request-cert.sh` to get initial TLS certificate
    - If not working, test that `http://<DOMAIN-NAME>/.well-known/acme-challenge` returns a non-303 error.
1. Now in `nginx/nginx.conf` add a block for **https** routing and reload configuration with `docker exec -it nginx nginx -s reload`. Future HTTPS certificate renewals will be handled by Certbot.
    - Test using: `docker compose run --rm --entrypoint certbot certbot renew --dry-run`
1. (Optional) If domain points to router, add local DNS record inside router's LAN for domain
1. Setup DDNS (NOTE: configuration is based on **domain registrar**)
    - See `ddns-updater/data` for configuring domain registered with Porkbun
    - Go to `localhost:9000` to see DDNS status (if updater is on host port 9000)

## CI/CD Pipeline 
Create cron job to run `auto-deploy.sh` every minute. `auto-deploy.sh` runs `deploy-if-changed.sh` and prints to log file. `deploy-if-changed.sh` fetches for changes in git repo and updates containers if found.

- NOTE: make sure to run `chmod +x <SCRIPT-PATH>` for all automated scripts
- NOTE: Use git repo's SSH remote url instead of HTTPS remote