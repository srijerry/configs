#! /bin/bash
slave_config() {

sudo apt-get update -y
sudo apt install default-jdk -y
java -version

if [ ! -d /opt/jenkins ]
then
     mkdir /opt/jenkins
     chmod 755 /opt/jenkins
     echo "directory created"
else
     echo "Directory exists"
fi


echo -e '\n' | ssh-keygen -N ""

cd ~/.ssh/

privatekey=$(cat /root/.ssh/id_rsa)

publicekey=$(cat /root/.ssh/id_rsa.pub)

hostname=$(hostname -i)

cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys

cat /root/.ssh/authorized_keys


echo "the private is : "$privatekey

echo "the public is : "$publicekey

echo "Hostname : "$hostname

}

slave_config