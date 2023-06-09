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
