#!/usr/bin/env bash

echo ' ### USER.SH ### '

while true; do
  read -rp "Enter new user name: " new_username
  while true; do
    read -rp "Enter new user password: " new_password
    printf "\n"
    if [[ $new_password =~ \  ]]; then
      pritnf "Error: Password should not contain spaces! \n"
    else
      break
    fi
  done

  read -rp "Repeat new user password: " new_password_repeat
  printf "\n"
  if [[ "$new_password" != "$new_password_repeat" ]]; then
    printf "Error: Passwords do not match! \n"
  else
    break
  fi
done

function add_user {
  local new_username="$1"
  local new_password="$2"
  # Add new sudoer
  sudo adduser --disabled-password --gecos "" "$new_username"
  sudo usermod -aG sudo "$new_username"
  sudo usermod -s /bin/bash "$new_username"
  echo "$new_username:$new_password" | sudo chpasswd -e

  sudo systemctl restart sshd
}

echo "Connecting to ${sshstr:?}..."

# shellcheck disable=SC2154
ssh "$sshstr" 'bash -s' < <(
  typeset -f add_user
  echo "add_user ${new_username} ${new_password}"
)

ssh_key_path="$HOME/.ssh/id_rsa.pub"

function copy_ssh_key {
  check_key_path() {
    read -rp "Is path to ssh keys correct ($ssh_key_path)? [Y/n]" correct
    if [[ $correct == '' || $correct == 'y' || $correct == 'Y' ]]; then
      test -f "$ssh_key_path" && return 0 || return 1
    elif [[ $correct == 'n' || $correct == 'N' ]]; then
      read -rp "Enter path to ssh keys: " ssh_key_path
      test -f "$ssh_key_path" && return 0 || return 1
    else
      echo "Error: invalid answer"
      check_key_path
    fi
  }

  read -rp "Do you want to copy ssh keys to remote? [Y/n] " flag
  if [[ $flag == '' || $flag == 'y' || $flag == 'Y' ]]; then
    check_key_path && ssh-copy-id -o User="$new_username" -i "$ssh_key_path" "$sshstr" && return 0 || return 1
  elif [[ $flag == 'n' || $flag == 'N' ]]; then
    echo "You can copy ssh keys later by running 'ssh-copy-id -o User=$new_username -i <path_to_ssh_key> $sshstr'"
    return 1
  else
    echo "Error: invalid answer"
    copy_ssh_key
  fi
}

function restrict_root_login {
  read -rp "Do you want to restrict root login? [Y/n] " secure
  if [[ $secure == '' || $secure == 'y' || $secure == 'Y' ]]; then
    ssh "$sshstr" 'bash -s' <<-EOF
      sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
      sudo systemctl restart sshd
EOF
    return 0
  elif [[ $secure == 'n' || $secure == 'N' ]]; then
    return 1
  else
    echo "Error: invalid answer"
    restrict_root_login
  fi
}

function restrict_password_auth {
  read -rp "Do you what to restrict password authentication? [Y/n] " secure
  if [[ $secure == '' || $secure == 'y' || $secure == 'Y' ]]; then
    ssh "$sshstr" 'bash -s' <<-EOF
      sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
      sudo systemctl restart sshd
EOF
    return 0
  elif [[ $secure == 'n' || $secure == 'N' ]]; then
    return 1
  else
    echo "Error: invalid answer"
    restrict_password_auth
  fi
}

if copy_ssh_key; then
  echo "SSH key copied successfully. Trying to login with SSH key..."
  if ssh -o "User=$new_username" "$sshstr" whoami; then
    restrict_root_login || echo "root login is not restricted"
    restrict_password_auth || echo "password authentication is not restricted"
  fi
else
  echo "Error: SSH key was not copied"
fi
