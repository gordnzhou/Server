DOMAIN_NAME="DOMAIN_NAME"
EMAIL="EMAIL"

cd /home/gordon/services

docker compose run --rm --entrypoint certbot certbot certonly \
  --webroot -w /var/www/certbot \
  -d "$DOMAIN_NAME" -d "www.$DOMAIN_NAME" \
  --email $EMAIL --agree-tos --no-eff-email -v

# creates certificate in: /etc/letsencrypt/live/$DOMAIN_NAME/