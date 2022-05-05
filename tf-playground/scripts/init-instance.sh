#!/bin/bash
# ec2 initialization setup
# user_data already launched as root (no need sudo -s)

# Must disable swappiness

echo 'Start ...'
apt-get update -y
apt-get install lxde -y
apt-get install xrdp -y