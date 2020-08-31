#!/bin/sh

apt update

#SETUP DOCKER

apt-get install apt-transport-https ca-certificates curl wget gnupg-agent software-properties-common -y

#Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
apt-key fingerprint 0EBFCD88

#set up the stable repository
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"

#sudo apt update
apt update
apt install docker-ce docker-ce-cli containerd.io -y


#install git
apt install git -y


#SETUP JENKINS

#install java
apt install default-jre -y

#Download the GPG Security Key
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -

#Add the Jenkins Repository to Your System
echo "deb https://pkg.jenkins.io/debian-stable binary/" > /etc/apt/sources.list.d/jenkins.list

#Install jenkins
apt update
apt install jenkins -y

usermod -a -G docker jenkins

#Enable and start the Jenkins service
systemctl enable --now jenkins

status=`systemctl is-active jenkins`
printf "%s\n" "$status"
if [[ "$status" != "active" ]]
then
   printf "Failed to start jenkins"
   exit
fi

printf "get jenkins-cli.jar file\n"
wget http://localhost:8080/jnlpJars/jenkins-cli.jar

printf "default password\n"
pass=`cat /var/lib/jenkins/secrets/initialAdminPassword`
printf $pass

#add jenkins user to /etc/sudoers files
echo "jenkins ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers

#install required plugins for jenkins

for plugin in `cat plugins.txt` 
do
  printf "\nInstalling %s plugin...\n" "$plugin"
  java -jar ./jenkins-cli.jar -s http://localhost:8080 -auth admin:$pass install-plugin $plugin
done


printf "restarting jenkins..."
systemctl restart jenkins


#SETUP ANSIBLE

#install pip3
apt install python3-pip -y

#install dependencies
pip3 install ansible openshift kubernetes kubernetes-validate 

printf "end of setup"





