#!/usr/bin/env bash

read -r "Enter domain name: " domain_name
read -r "Enter repository link" repo

# Prompt the user to enter a repository alias and check for spaces
while true; do
  read -r "Enter local repository name: " alias
  if [[ "$alias" =~ " " ]]; then
    echo "Error: Repository alias cannot contain spaces."
  else
    break
  fi
done

# Install dependencies
sudo apt update
sudo apt install -y python3-certbot-nginx git

read -r "Enter github repository HTTP URL: " repo

sudo git clone "$repo" "/var/www/$alias"
sudo git -C "/var/www/$alias" checkout max/infra-setup
sudo git -C "/var/www/$alias" -school pull

# Setup repo
sudo ln -sf "/var/www/$alias/nginx.conf" "/etc/nginx/conf.d/$alias.conf"

# Generate SSL certificate
sudo certbot --nginx --agree-tos --redirect --non-interactive --email wtf403@yandex.ru --domains "$domain_name"

# Restart nginx
sudo service nginx restart
