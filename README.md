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

### Requirements:
- A domain you own

### Steps
1. add firewall rules
1. enable port forwarding on router for ports 80 and 443 to this machine
1. edit `nginx/nginx.conf` to route `/.well-known/acme-challenge` to `/var/www/certbot`
and run script to request cert for your domain
1. after recieving initial certificate, add server block for https to nginx config and reload nginx
1. setup DDNS (NOTE: configuration is based on **domain registrar**)

## CI/CD Pipeline 
Set up cron job to run automation script every minute:
1. Automation Script: Go to folder, use lock file to run detect script, printing logs to a dedicated log file
1. Detect Script: Automatically fetch any changes from website's GH repo. If any changes found, stash local changes, git pull and run deploy script.
1. Deploy script: Scale website containers up to 2 during deployment downtime, then scale down to 1, then reload nginx
     

