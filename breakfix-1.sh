#!/bin/bash

read -p "Do you want to install Apache? (y/n) " answer

if [[ $answer = y ]]; then
    # Install Apache
    sudo dnf install httpd -y

    # Start Apache
    sudo systemctl start httpd

    # Enable Apache to start at boot
    sudo systemctl enable httpd
else
    echo "Apache installation skipped and proceeding for setting up Breakfix lab."
fi

# Comment out the line ending with "combined" in httpd.conf using sed and remove the %h parameter
if sudo sed -i '/combined$/ s/^/#/' /etc/httpd/conf/httpd.conf &&
   sudo sed -i 's/%h//' /etc/httpd/conf/httpd.conf; then
    # Restart Apache
    sudo systemctl restart httpd
else
    echo "Failed to modify httpd.conf"
fi

# Set up virtual host for exampleone.com
sudo tee /etc/httpd/conf.d/exampleone.com.conf > /dev/null <<EOF
<VirtualHost *:80>
    ServerName exampleone.com
    DocumentRoot /var/www/html/exampleone.com
    ErrorLog /var/log/httpd/exampleone.com-error.log
    CustomLog /var/log/httpd/exampleone.com-access.log combined
    <Directory /var/www/html/$domain>
                Options -Indexes +FollowSymLinks -MultiViews
                AllowOverride All
                Require all granted
   </Directory>

</VirtualHost>
EOF

# Create document root directory for exampleone.com
sudo mkdir -p /var/www/html/exampleone.com

# Set permissions for document root directory
sudo chown -R apache:apache /var/www/html/exampleone.com

# Create an index.html file
echo "exampleone.com is working" | sudo tee /var/www/html/exampleone.com/index.html > /dev/null

# Reload Apache to apply changes
sudo systemctl reload httpd

echo "Breakfix lab setup completed!"

