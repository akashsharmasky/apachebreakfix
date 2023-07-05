#!/bin/bash

domain=exampletwo.com

read -p "Do you want to install Apache? (y/n) " answer

if [[ $answer = y ]]; then
    # Install Apache
    sudo dnf install httpd -y


    # Start Apache if not already running
    if ! sudo systemctl is-active --quiet httpd; then
        sudo systemctl start httpd
    fi

    # Enable Apache to start at boot
    sudo systemctl enable httpd
fi

echo " Seting up virtual host for port 80 with server name $domain"
    sudo tee /etc/httpd/conf.d/$domain.conf > /dev/null <<EOF
<VirtualHost *:80>
    ServerName $domain
    DocumentRoot /var/www/html/$domain
    ErrorLog /var/log/httpd/$domain-error.log
    CustomLog /var/log/httpd/$domain-access.log combined
   <Directory /var/www/html/$domain>
                Options -Indexes +FollowSymLinks -MultiViews
                AllowOverride All
                Require all granted
   </Directory>
</VirtualHost>
EOF



 echo
 echo "setting up LAB Breakfix"

 sudo mkdir /var/www/html/$domain
  
 sudo systemctl reload httpd


 cd /var/www/html/$domain

# Create a index.html file
echo "exampletwo.com is working" > index.html

# Download the image
wget https://www.rackspace.com/sites/default/files/article-images/rackspace-technology.jpg

# Check if the file exists
if ls rackspace-technology.jpg &> /dev/null; then
    echo "JPG file has been downloaded."
else
    echo "JPG file is not downloaded due to some issue, pls download manually from https://www.rackspace.com/sites/default/files/article-images/rackspace-technology.jp in document root"
fi	 
 

 
# Variables
#file="/etc/httpd/conf/httpd.conf"
#line_number=132
#lines_to_add="<Directory /var/www/html/\$domain>
#<IfModule mod_rewrite.c>
#  RewriteEngine On
#  RewriteRule \\\.jpg$ - [F]
#</IfModule>
#</Directory>"


# Add lines to the file at the specified line number
#sudo sed -i "${line_number}i ${lines_to_add}" "$file" 

# Add lines to httpd.conf
if sudo sed -i '132i\<Directory /var/www/html/exampletwo.com>\n<IfModule mod_rewrite.c>\nRewriteEngine On\nRewriteRule \\\.jpg$ - [F]\n</IfModule>\n</Directory>' /etc/httpd/conf/httpd.conf; sudo sed -i '183i<Files "*.html">\n  Require all denied\n</Files>\n\n<Files "*.php">\n  Require all denied\n</Files>' /etc/httpd/conf/httpd.conf; then
       # Reload Apache
        sudo systemctl reload httpd
    else
        echo "Failed to add lines to httpd.conf"
    fi

    # Add lines to httpd.conf
#    if sudo sed -i '183i<Files "*.html">\n  Require all denied\n</Files>\n\n<Files "*.php">\n  Require all denied\n</Files>' /etc/httpd/conf/httpd.conf; then
        # Reload Apache
#        sudo systemctl reload httpd
#    else
#        echo "Failed to add lines to httpd.conf"
#    fi



echo "lab has been setup, Domain name is $domain"
echo
echo "Image url is "$domain/rackspace-technology.jpg
