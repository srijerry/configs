#!/bin/bash

# Install Java
sudo apt-get update
sudo apt install default-jdk -y
java -version


# Install Jenkins
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io.key | sudo tee \
    /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
    https://pkg.jenkins.io/debian binary/ | sudo tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update
sudo apt-get install jenkins -y

# Start Jenkins
sudo systemctl start jenkins

# Get initial admin password
echo "Initial admin password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword