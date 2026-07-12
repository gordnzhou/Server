# Server Setup


## Initial Setup 

### Requirements
- Machine running Linux connected to the internet

### Steps
1. Install docker onto machine
1. Do `mkdir services`. Copy `docker-compose.yml` and `nginx/nginx.conf` to `services/`
1. Clone website repo into `services/` and configure `docker-compose.yml`
    - edit `nginx/nginx.conf` to listen to localhost at port 80 to test locally first
1. (Optional) To test website locally without containers, install Node and NPM
1. To build and start containers with `docker compose up --build`. Check containers' status with `docker ps`

## Deploying to the Internet

### Prereqs:
- A domain with records that point to home router's public IP / your desired IP

### Steps
1. Add firewall rules on server machine
1. On router, Enable port forwarding for ports 80 and 443 to the server machine
    - Verify that ports are [open on your router](https://www.yougetsignal.com/tools/open-ports/)
    - **All** inbound requests from port 80 and 443 will route through Nginx first
1. Edit `nginx/nginx.conf` with domain name, and route `/.well-known/acme-challenge` to `/var/www/certbot`. Run `request-cert.sh` to get initial TLS certificate.
    - If not working, test that `http://<DOMAIN-NAME>/.well-known/acme-challenge` returns a non-303 error.
1. Now in `nginx/nginx.conf`, add a block for **https** routing and reload configuration with `docker exec -it nginx nginx -s reload`. Future HTTPS certificate renewals will be handled by Certbot.
    - Test using: `docker compose run --rm --entrypoint certbot certbot renew --dry-run`
1. (Optional) If domain points to router, add local DNS record inside router's LAN (via Pi-Hole) for domain
1. Setup and run DDNS container (NOTE: configuration is based on **domain registrar**)
    - `ddns-updater/data` has Porkbun configuration
    - Go to `localhost:9000` to see DDNS status (if DDNS container is on host port 9000)

## CI/CD Pipeline 
Create cron job to run `auto-deploy.sh` every minute. `auto-deploy.sh` runs `deploy-if-changed.sh` and prints to a log file. `deploy-if-changed.sh` fetches for changes in git repo and updates containers if found. Ensures zero downtime by scaling website containers to 2 during build, then scaling back to 1.

- NOTE: make sure to run `chmod +x <SCRIPT-PATH>` for all automated scripts
- NOTE: Use git repo's SSH remote url instead of HTTPS remote