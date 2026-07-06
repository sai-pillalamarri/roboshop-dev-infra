#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
  echo "ERROR: component name, environment name and version are required"
  echo "USAGE: sh bootstrap.sh <component> <environment> <version>"
  exit 1
fi

component=$1
environment=$2
version=$3

sudo mkdir -p /var/log/roboshop
sudo chown -R ec2-user:ec2-user /var/log/roboshop
sudo touch /var/log/roboshop/$component.log
sudo chmod 755 /var/log/roboshop/$component.log

sudo dnf install ansible -y

cd /home/ec2-user

if [ -d roboshop-ansible-v3 ]; then
  echo "Repo already exists - pulling latest..."
  cd roboshop-ansible-v3
  git pull
else
  echo "Cloning repo..."
  git clone https://github.com/sai-pillalamarri/roboshop-ansible-v3.git
  cd roboshop-ansible-v3
fi

echo "Running ansible for $component"
ansible-playbook -e "component=$component" -e "env=$environment" -e "version=$version" roboshop.yaml &>> /var/log/roboshop/$component.log

if [ $? -eq 0 ]; then
  echo "$component configured successfully"
else
  echo "ERROR: ansible failed for $component - check /var/log/roboshop/$component.log"
  exit 1
fi