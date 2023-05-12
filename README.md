# Ansible playbooks for Ubuntu server

This repository contains a set of Ansible playbooks for Ubuntu server initial setup that can be run using [multiselect menu](multiselect.miu.io)

## Requirements

The playbooks in this repository require Ansible to be installed on the local machine and SSH access to the remote server.  
Additionally, for SSH password authentication `sshpass` package required

## Usage

- Clone the repo:  
  `git clone https://github.com/wtf403/ubuntu-prepare.git`
- Set the permissions:
  `chmod +x main.sh`
- Run main.sh and provide SSH connection string
- Some playbooks may also require root user credentials

## Available Playbooks
