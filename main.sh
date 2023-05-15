#!/usr/bin/env bash

#shellcheck source=/dev/null
source utils/spinner.sh

url="https://raw.githubusercontent.com/mamiu/dotfiles/master/install/utils/multiselect.sh"
if [[ $(wget -S --spider "$url" 2>&1 | grep "HTTP/1.1 200 OK") == "" ]]; then
  echo "Error: $url not found"
  exit 1
else
t  #shellcheck source=/dev/null
  source <(spinner "wget -qO- $url" "multiselect.miu.io")
fi

result=()
scripts=("user.sh" "utils.sh" "nginx.sh")
_preselection=("true" "true" "false")
multiselect "true" result scripts _preselection

# shellcheck disable=SC2034
read -rp "Enter SSH connection string: " sshstr

# Check if all values in result are false
all_false=true
for i in "${!result[@]}"; do
  if [[ "${result[i]}" == "true" ]]; then
    all_false=false
    #shellcheck source=/dev/null
    source scripts/"${scripts[i]}"
  fi
done

if [[ "$all_false" == true ]]; then
  echo "Error: No scripts selected"
  exit 1
fi
