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

#shellcheck source=/dev/null
source <(spinner 'curl -sL multiselect.miu.io' 'fetching multiselect from multiselect.miu.io')

result=()
_playbooks=("Option 1" "Option 2" "Option 3")
_preselection=("true" "true" "false")
multiselect "true" result _playbooks _preselection

for i in "${result[@]}"; do
  echo "$i"
done
