#!/bin/bash

sudo su -
pwd 
cd /opt/
mkdir jenkins
chmod 755 jenkins
cd jenkins

remote_root_dir=$pwd

echo -e "\n\n\n" | ssh-keygen

cd ~/.ssh/

privatekey=$cat id_rsa

publicekey=$cat id_rsa.pub

hostname=$hostname -i

cat id_rsa >> authorized_keys



echo "$remote_root_dir"

echo "$privatekey"

echo "$publicekey"

echo "$hostname"