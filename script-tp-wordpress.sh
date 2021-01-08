#!/usr/bin/env bash

apt-get update
apt-get install -y apache2 mysql-client php libapache2-mod-php php-cli php-common php-mbstring php-gd php-intl php-xml php-mysql php-zip php-curl php-xmlrpc unzip
cd /tmp
wget https://www.wordpress.org/latest.tar.gz
tar xzvf /tmp/latest.tar.gz --strip 1 -C /var/www/html
rm /tmp/latest.tar.gz
rm -f /var/www/html/index.html
chown -R www-data:www-data /var/www/html/
chmod -R 755 /var/www/html/
systemctl enable apache2
curl -o /var/www/html/wp-config.php https://raw.githubusercontent.com/WordPress/WordPress/master/wp-config-sample.php
sed -i 's/username_here/admin/' /var/www/html/wp-config.php
sed -i 's/password_here/${password}/' /var/www/html/wp-config.php
sed -i 's/localhost/${endpoint}/' /var/www/html/wp-config.php
sed -i 's/database_name_here/wordpress/' /var/www/html/wp-config.php
systemctl restart apache2