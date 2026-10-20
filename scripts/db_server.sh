#!/bin/bash -xe
exec > /var/log/install.log 2>&1
apt update
apt upgrade -y
apt install mysql-server -y
sed -i "s|^bind-address.*|bind-address = 0.0.0.0|" /etc/mysql/mysql.conf.d/mysqld.cnf
systemctl restart mysql
mysql -e "CREATE USER 'dedicado'@'%' IDENTIFIED BY 'secret';"
mysql -e "CREATE DATABASE dedicada;"
#mysql -e "CRETE TABLE ...."