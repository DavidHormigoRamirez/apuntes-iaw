#!/bin/bash -xe
exec > /var/log/install.log 2>&1
apt update
apt upgrade -y
apt install apache2 -y
apt install mysql-client -y
apt install php -y