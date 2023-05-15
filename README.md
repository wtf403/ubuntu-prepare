# Ubuntu server initial setup

This repository contains bash scripts for initial Ubuntu setup with [multiselect](multiselect.miu.io) menu for choosing only options you need. The script should run on your local computer with SSH access to the server

## Usage

- Generate ssh keys if you have't one:  
  `ssh-keygen -t ed25519 -C "your_email@example.com"`
- Clone repository to your local machine:  
  `git clone https://github.com/wtf403/ubuntu-prepare.git`
- Give permissions to the `main.sh` file:  
  `chmod +x main.sh`
- Run script and select the necessary options
  `./main.sh`
