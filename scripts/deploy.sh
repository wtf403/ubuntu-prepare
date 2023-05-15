#!/usr/bin/env bash

echo ' ### DEPLOY.SH ### '

read -rp "Enter domain name: " domain_name
read -rp "Enter repository link" repo
read -rp "Enter github repository HTTP URL: " repo

# Prompt the user to enter a repository alias and check for spaces
while true; do
  read -rp "Enter local repository name: " alias
  if [[ "$alias" =~ " " ]]; then
    echo "Error: Repository alias cannot contain spaces."
  else
    break
  fi
done

function deploy() {
  # Install dependencies
  apt update
  apt install -y python3-certbot-nginx git

  git clone "$repo" "/var/www/$alias"
  git -C "/var/www/$alias" checkout max/infra-setup
  git -C "/var/www/$alias" -school pull

  # Setup repo
  ln -sf "/var/www/$alias/nginx.conf" "/etc/nginx/conf.d/$alias.conf"

  # Generate SSL certificate
  certbot --nginx --agree-tos --redirect --non-interactive --email wtf403@yandex.ru --domains "$domain_name"

  # Restart nginx
  service nginx restart
}

echo "Compiling nginx from sorces. This may take a while..."

# shellcheck disable=SC2154
ssh "$sshstr" 'bash -s' < <(
  typeset -f deploy
  echo "deploy"
)

# shellcheck disable=SC2181
if [[ $? -eq 0 ]]; then
  echo "Nginx installed successfully"
else
  echo "Nginx installation failed"
fi
