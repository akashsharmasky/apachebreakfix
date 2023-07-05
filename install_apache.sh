#!/bin/bash

# Install Apache
#sudo dnf install httpd -y

# Start Apache
#sudo systemctl start httpd

# Enable Apache to start at boot
#sudo systemctl enable httpd

# Show Apache service status
#sudo systemctl status httpd -l

# Create a test index file
echo "Website is working fine" > /var/www/html/index.html

curl localhost
 

