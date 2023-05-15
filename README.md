# Ubuntu server initial setup

This repository contains bash scripts fo [multiselect menu](multiselect.miu.io)

## Requirements

The playbooks in this repository require Ansible to be installed on the local machine and SSH access to the remote server.  
Additionally, for SSH password authentication `sshpass` package required

## Usage

- Generate ssh keys if you have't one
- Clone main script to your local machine:  
  `wget -qO- \
    https://raw.githubusercontent.com/wtf403/ubuntu-prepare/main/main.sh | bash`  
    or  
    `curl -sL https://raw.githubusercontent.com/wtf403/ubuntu-prepare/main/utils/spinner.sh | bash`
