#!/usr/bin/env bash

exec 4>&1
spinner() {
  eval "$1" >&3 &
  local message=$2
  local pid=$!
  local delay=0.1
  local spinstr='\-|/'
  while true; do
    if ps a | awk '{print $1}' | grep -q "$pid"; then
      local temp=${spinstr#?}
      printf "%c %s" "$spinstr" "$message"
      local spinstr=$temp${spinstr%"$temp"}
      sleep $delay
      printf "\b\b%${#message}s" | tr " " "\b"
      continue
    else
      printf "%s\n\n" "$message"
      break
    fi
  done
} 3>&1 1>&4

url="https://raw.githubusercontent.com/mamiu/dotfiles/master/install/utils/multiselect.sh"
if [[ $(wget -S --spider "$url" 2>&1 | grep "HTTP/1.1 200 OK") == "" ]]; then
  echo "Error: $url not found"
  exit 1
else
  #shellcheck source=/dev/null
  source <(spinner "wget -qO- $url" "multiselect.miu.io")
fi

result=()
_scripts=("utils.sh" "user.sh" "nginx.sh")
_preselection=("true" "true" "false")
multiselect "true" result _scripts _preselection

# shellcheck disable=SC2034
read -rp "Enter SSH connection string: " sshstr

for i in "${!result[@]}"; do
  if [[ "${result[i]}" == "true" ]]; then
    url="https://raw.githubusercontent.com/wtf403/ubuntu-prepare/main/scripts/${_scripts[i]}"

    if [[ $(wget -S --spider "$url" 2>&1 | grep "HTTP/1.1 200 OK") == "" ]]; then
      echo "Error: $url not found"
    else
      #shellcheck source=/dev/null
      source <(spinner "wget -qO- $url" "fetch ${result[i]}")
    fi
  fi
done

# TODO:
# - tmp files for fetched resources
# - write tests for each script
