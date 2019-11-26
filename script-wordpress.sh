#!/bin/bash

sudo apt-get update
sudo apt-get install -y apache2 mysql-client php libapache2-mod-php php-cli php-common php-mbstring php-gd php-intl php-xml php-mysql php-zip php-curl php-xmlrpc unzip
cd /tmp 
wget -c http://wordpress.org/latest.tar.gz ; tar -xzvf latest.tar.gz
sudo rm -f /var/www/html/index.html
sudo mv wordpress/* /var/www/html/
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/
sudo systemctl restart apache2
