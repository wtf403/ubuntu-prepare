#!/usr/bin/env bash

#shellcheck source=/dev/null
source <(wget -qO- https://raw.githubusercontent.com/wtf403/ubuntu-prepare/main/utils/spinner.sh)

url="https://raw.githubusercontent.com/mamiu/dotfiles/master/install/utils/multiselect.sh"
if [[ $(wget -S --spider "$url" 2>&1 | grep "HTTP/1.1 200 OK") == "" ]]; then
  echo "Error: $url not found"
  exit 1
else
  #shellcheck source=/dev/null
  source <(spinner "wget -qO- $url" "multiselect.miu.io")
fi

result=()
_utils=("curl" "nvim" "git")
_preselection=("true" "true" "false")
multiselect "true" result _scripts _preselection

install=()

apt update
apt upgrade -y

for i in "${!result[@]}"; do
  if [[ "${result[i]}" == "true" ]]; then
    install+=("${_utils[i]}")
  fi
done

read -r "Enter user to install utils: " user

# shellcheck disable=SC2087
ssh -o "User=$user" "${sshstr:?}" 'bash -s' <<-EOF
  sudo apt install -y ${install[@]}
EOF
