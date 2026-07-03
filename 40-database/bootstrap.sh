#!/bin/bash

if [ -z "$1" ]; then 
	echo "ERROR: component name required"
	echo "USAGE: sudo sh bootstrap.sh <component_name>"
	exit 1
fi

if [ -z "$2" ]; then
  echo "ERROR: environment name required"
  echo "USAGE: sudo sh bootstrap.sh <component_name> <environment>"
  exit 1
fi

component=$1
environment=$2

sudo dnf install ansible -y
mkdir -p /var/log/roboshop
chown -R ec2-user:ec2-user /var/log/roboshop

touch /var/log/roboshop/$component.log
chmod 755 /var/log/roboshop/$component.log

cd /home/ec2-user

if [ -d "roboshop-ansible-v3" ];then
	echo "Repo alredy exists - pulling latest.."
	cd roboshop-ansible-v3
	git pull
else
   echo "Cloning Repo.."
   git clone https://github.com/sai-pillalamarri/roboshop-ansible-v3.git
   cd roboshop-ansible-v3
fi

echo "Running ansible for $component"
ansible-playbook -e "component=$component" -e "env=$environment" roboshop.yaml &>> /var/log/roboshop/$component.log

if [ $? -eq 0 ]; then
   echo "$component configured succesfully" 

else
	echo "Error: ansible failed for $component - check /var/log/roboshop/$component.log" 
	exit 1

fi