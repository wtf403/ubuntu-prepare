#!/usr/bin/env bash

result=()
utils=("git" "curl" "nvim")
_preselection=("true" "true" "false")
echo "Select utils to install:"
multiselect "true" result utils _preselection

install=()

for i in "${!result[@]}"; do
  if [[ "${result[i]}" == "true" ]]; then
    install+=("${utils[i]}")
  fi
done

read -r "Enter user on ${sshstr:?} to install utils: " user

# shellcheck disable=SC2087
ssh -o "User=$user" "${sshstr:?}" 'bash -s' <<-EOF
  apt update -y && apt upgrade -y
  apt install -y ${install[@]}
EOF
