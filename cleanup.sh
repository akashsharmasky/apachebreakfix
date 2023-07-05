#!/bin/bash

# Ask if Apache should be removed
read -p "Do you want to remove Apache? (y/n) " answer

if [[ $answer = y ]]; then
    # Stop Apache if running
    if sudo systemctl is-active --quiet httpd; then
        sudo systemctl stop httpd
    fi

    # Remove Apache packages
    sudo dnf remove httpd -y

    # Remove Apache configuration files and log directories
    sudo rm -rf /etc/httpd/ /var/log/httpd/
fi

#Ask if php-fpm should be removed
read -p "Do you want to remove php-fpm? (y/n) " answer

if [[ $answer = y ]]; then
   #stop php-fpm if running
   if sudo systemctl is-active --quiet php-fpm; then
       sudo systemctl stop php-fpm
    fi
 # Remove php-fpm and related packages
 sudo dnf remove php php-fpm php-mysqlnd php-gd php-xml php-mbstring -y

# Remove Apache configuration files and log directories
rm -rf /etc/php-fpm.d /var/log/php-fpm/ /etc/php.ini /etc/php.d
fi


# Ask if MySQL should be removed
read -p "Do you want to remove MySQL? (y/n) " answer

if [[ $answer = y ]]; then
    # Stop MySQL if running
    if sudo systemctl is-active --quiet mariadb; then
        sudo systemctl stop mariadb
    fi

    # Remove MySQL packages
    sudo dnf remove mariadb-server mariadb -y

    # Remove MySQL data directory
    sudo rm -rf /var/lib/mysql/
fi

# Remove Apache document root directory
sudo rm -rf /var/www/html/*

echo "cleanup is done"
