#!/bin/bash
# ec2 initialization setup
# user_data already launched as root (no need sudo -s)

echo 'Start ...'
apt-get update -y

USER_NAME=ubuntu
PASSWD=ubuntu
USR_HOME=/home/$USER_NAME
DEST=$USR_HOME/tos
TOS_RELEASE=TOS_DI-20211109_1610-V8.0.1

mkdir $DEST
wget -P $DEST https://a-materials-rch.s3.eu-north-1.amazonaws.com/install-packages/xulrunner-1.9.2.28pre.en-US.linux-x86_64.tar.bz2
wget -P $DEST https://a-materials-rch.s3.eu-north-1.amazonaws.com/install-packages/$TOS_RELEASE.zip

apt-get install lxde -y 
apt-get install xrdp -y

apt install default-jre -y
apt install default-jdk -y
apt install maven -y

unzip $DEST/TOS_DI-20211109_1610-V8.0.1.zip -d $DEST
tar xvfj $DEST/xulrunner-1.9.2.28pre.en-US.linux-x86_64.tar.bz2 -C $DEST
sleep 10

# add this in .profile
echo "export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64" >> /home/ubuntu/.profile
echo "export PATH=/\$JAVA_HOME/bin:\$PATH" >> /home/ubuntu/.profile

# Install Couchbase Talend Connector
cd $USR_HOME
git clone https://github.com/Talend/connectors-se.git
sleep 5
TALEND_REPO_DIR=$USR_HOME/connectors-se

cd $TALEND_REPO_DIR/couchbase
mvn clean install -DskipTests talend-component:deploy-in-studio -Dtalend.component.studioHome="$DEST/$TOS_RELEASE/"

# assign permissions to user
chown -R $USER_NAME.$USER_NAME $TALEND_REPO_DIR
chmod -R 755 $TALEND_REPO_DIR
chown -R $USER_NAME.$USER_NAME $DEST
chmod -R 755 $DEST

# assign a pass to user
echo -en "$PASSWD\n$PASSWD\n" | passwd $USER_NAME