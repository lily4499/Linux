# Wordpress_creation
# What this script does:
# 1- Updates the packages.
# 2- Install Apache web server.
# 3- Install PHP and requirements.
# 4- Install MySQL.
# 5- Install wordpress.



#!/bin/bash
# Description: Script to automate Wordpress's creation on centos 7
# Author: Liliane Konissi

# Install script for Latest WordPress on local dev
echo "Automate creation of Wordpress on centos 7"
echo "first, we are going to update our system"

yum update -y

# Installing LAMP Stack on CentOs 7
echo "verify httpd"
httpd -v
if [ $? -ne 0 ]
then
echo "httpd is not installed"
yum install httpd -y
else
echo "httpd is installed"
fi

echo "start Apache server"
systemctl start httpd

# To enable Apache on boot, run
echo "enable Apache"
systemctl enable httpd

echo "verify is default port httpd is open"
lsof -i -P -n | grep httpd
if [ $? -ne 0 ]
then
echo " default port httpd is not open"
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --reload
else
echo "default port httpd is open"
fi

service httpd restart

echo "verify httpd-service on the browser"


# Since we are going to use php7.3, we will need to disable the installation of php5.4
# using yum-config-manager command provided by yum-utils tool.
echo
echo "verify php is install"
php -v
if [ $? -ne 0 ]
then
echo "php is not installed"
yum install php-cli -y
else
echo "php is installed"
fi

echo "verify php version"
VER=`php -v | grep cli | awk '{print$2}' | awk -F. '{print$1}'`
PHP=7
if [ $VER -lt $PHP ]
then
echo "Installing Remi Repository on CentOS 7"
yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
yum -y install epel-release yum-utils
echo "disable PHP 5.4."

yum-config-manager --disable remi-php54
echo "now enable PHP 7.3"
sudo yum-config-manager --enable remi-php73
echo "Install PHP 7.3 on CentOS 7"
yum -y install php php-cli php-fpm php-mysqlnd php-zip php-devel php-gd php-mcrypt php-mbstring php-curl php-xml php-pear php-bcmath php-json
echo "check version installed"
php -v
echo 'restart httpd'
service httpd restart
elif  [ $VER -ge $PHP ]
then
php -v
fi

#echo "install the component of PHP"
#sudo yum install php php-common php-mysql php-gd php-xml php-mbstring php-mcrypt -y


echo "verify mariadb-server"
systemctl status mariadb
if [ $? -ne 0 ]
then
echo "mariadb is not installed"
yum install mariadb mariadb-server -y
else
echo "mariadb is installed"
fi

# Next, you need to start the MariaDB database server.
echo "start mariadb"
systemctl start mariadb

# Again, to enable it on boot, run
echo "enable maridb"
systemctl enable mariadb

echo "set up wordpress"
# Path to MySQL
MYSQL='/usr/bin/mysql'

# DB Variables
echo "MySQL Host:"
read mysqlhost
export mysqlhost

echo "MySQL DB Name:"
read mysqldb
export mysqldb

echo "MySQL DB User:"
read mysqluser
export mysqluser

echo "MySQL User Password:"
read mysqlpass
export mysqlpass

# WP Variables
#echo "Site Title:"
#read wptitle
#export wptitle

echo "Admin Username:"
read wpuser
export wpuser

echo "Admin Password:"
read wppass
export wppass

#echo "Admin Email"
#read wpemail
#export wpemail

# Site Variables
#echo "Site URL (ie, www.youraddress.com):"
#read siteurl
#export siteurl



echo "You will now be prompted for your MySQL password"

mysql_secure_installation


# Setup DB & DB User
$MYSQL -u root -p$mysqlrootpass -e "CREATE DATABASE $mysqldb; CREATE USER '$mysqluser'@'$mysqlhost' IDENTIFIED BY '$mysqlpass'; GRANT ALL PRIVILEGES ON $mysqldb.* TO '$mysqluser'@'$mysqlhost' IDENTIFIED BY '$mysqlpass'; FLUSH PRIVILEGES; "

echo "install php-mysql "
yum install php php-mysql -y
cd /var/www/html/
rm -f info.php
touch info.php
echo "info.php" >> info.php
echo "<?php" >> info.php
echo "phpinfo();" >> info.php
echo "?>" >> info.php
cat info.php

# Download latest WordPress and uncompress
echo "set up wordpress"
cd /tmp
yum install wget
wget https://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz.1
cp -r wordpress/* /var/www/html/
cd /var/www/html/
mkdir /var/www/html/wp-content/uploads
touch wp-config.php
# Build our wp-config.php file

sed -e "s/localhost/"$mysqlhost"/" -e "s/database_name_here/"$mysqldb"/" -e "s/username_here/"$mysqluser"/" -e "s/password_here/"$mysqlpass"/" wp-config-sample.php > wp-config.php
chown -R apache:apache /var/www/html/*
service httpd restart
