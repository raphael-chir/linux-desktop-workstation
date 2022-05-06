#!/bin/bash
# ec2 initialization setup
# user_data already launched as root (no need sudo -s)

echo 'Start ...'
apt-get update -y

USER_NAME=ubuntu
PASSWD=ubuntu
USR_HOME=/home/$USER_NAME
DEST=$USR_HOME/tos

mkdir $DEST
wget -P $DEST https://a-materials-rch.s3.eu-north-1.amazonaws.com/install-packages/xulrunner-1.9.2.28pre.en-US.linux-x86_64.tar.bz2
wget -P $DEST https://a-materials-rch.s3.eu-north-1.amazonaws.com/install-packages/TOS_DI-20211109_1610-V8.0.1.zip

apt-get install lxde -y 
apt-get install xrdp -y

sudo apt install default-jre -y
sudo apt install default-jdk -y

unzip $DEST/TOS_DI-20211109_1610-V8.0.1.zip -d $DEST
tar xvfj $DEST/xulrunner-1.9.2.28pre.en-US.linux-x86_64.tar.bz2 -C $DEST
sleep 10
chown -R $USER_NAME.$USER_NAME $DEST
chmod -R 755 $DEST

# add this in .profile
echo "export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64" >> /home/ubuntu/.profile
echo "export PATH=/\$JAVA_HOME/bin:\$PATH" >> /home/ubuntu/.profile

# assign a pass to user
echo -en "$PASSWD\n$PASSWD\n" | passwd $USER_NAME