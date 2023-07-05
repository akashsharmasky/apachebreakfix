#!/bin/bash

 echo  "Installing  Apache and PHP-FPM along with necessary PHP packages"
sudo yum install -y httpd php-fpm php php-common

echo " Creating a vhost for examplethree.com and configure PHP-FPM pool with name examplethree"
#sudo cp /etc/php-fpm.d/www.conf /etc/php-fpm.d/examplethree.conf
#sudo sed -i 's/www/examplethree/g' /etc/php-fpm.d/examplethree.conf

echo "
[examplethree]
user = apache
group = apache
listen = /run/php-fpm/examplethree.sock
listen.owner = apache
listen.group = apache
pm = dynamic
pm.max_children = 10
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 10
" > /etc/php-fpm.d/examplethree.conf

# Check PHP configuration for errors
if ! php-fpm -t; then
    echo "Error: PHP configuration contains errors."
    exit 1
fi

# Restart PHP-FPM
systemctl restart php-fpm.service


echo "Configure vhost to use the examplethree pool"
sudo mkdir /var/www/html/examplethree.com
sudo chown -R apache:apache /var/www/html/examplethree.com
sudo echo "<html><body><h1>Example Three</h1></body></html>" > /var/www/html/examplethree.com/index.html

echo "
<VirtualHost *:80>
    ServerName examplethree.com
    DocumentRoot /var/www/html/examplethree.com
    <Directory /var/www/html/examplethree.com>
        AllowOverride All
        Require all granted
    </Directory>
    <FilesMatch \.php$>
        SetHandler 'proxy:unix:/run/php-fpm/examplethree.sock|fcgi://localhost'
    </FilesMatch>
</VirtualHost>
" > /etc/httpd/conf.d/examplethree.com.conf



# Set max_children to 10 in PHP-FPM pool
#sudo sed -i 's/^pm.max_children = .*/pm.max_children = 10/' /etc/php-fpm.d/examplethree.conf
#sudo sed -i 's/^\(pm.max_children = \).*/\110/; s/^\(pm.max_spare_servers = \).*/\110/' /etc/php-fpm.d/examplethree.conf

# Comment out event MPM and enable prefork MPM
sed -i 's/^LoadModule mpm_event_module/#LoadModule mpm_event_module/' /etc/httpd/conf.modules.d/00-mpm.conf
sed -i 's/^#LoadModule mpm_prefork_module/LoadModule mpm_prefork_module/' /etc/httpd/conf.modules.d/00-mpm.conf

# Append prefork MPM configuration
echo '<IfModule mpm_prefork_module>' >> /etc/httpd/conf.modules.d/00-mpm.conf
echo 'MaxRequestWorkers 10' >> /etc/httpd/conf.modules.d/00-mpm.conf
echo 'ServerLimit 10' >> /etc/httpd/conf.modules.d/00-mpm.conf
echo '</IfModule>' >> /etc/httpd/conf.modules.d/00-mpm.conf

# Check Apache configuration for errors
if ! httpd -t; then
    echo "Error: Apache configuration contains errors."
    exit 1
fi

# Restart Apache and PHP-FPM
systemctl restart httpd.service



# Append following line "127.0.0.1 examplethree.com" in /etc/hosts file
echo "127.0.0.1 examplethree.com" >> /etc/hosts

# Setup epel repo 
sudo yum install -y epel-release 2>/dev/null

# Install screen package
sudo yum install -y screen 2>/dev/null

# Check if httpd-tools package is installed, if not install then install it.
if ! rpm -q httpd-tools; then
    sudo yum install -y httpd-tools
fi

# Start a screen session in background with following benchmark command "ab -n 1000 -c 10 http://examplethree.com/"
#screen -d -m ab -n 1000 -c 10 http://examplethree.com/


#####

SCRIPT_FILE="/var/www/html/examplethree.com/resource_testing.php"

# Create PHP script that doesn't require MySQL and uses a lot of resources:
sudo tee "${SCRIPT_FILE}" > /dev/null << EOF
<?php
// Increase memory limit to 1GB
ini_set('memory_limit', '1050M');

// Allocate 512MB of memory
\$memory = str_repeat('x', 1024 * 1024 * 512);

// Sort an array of 10 million random numbers
\$array = range(1, 10000000);
shuffle(\$array);
sort(\$array);

// Calculate the factorial of 100,000
function factorial(\$n) {
    if (\$n === 0) {
        return 1;
    } else {
        return \$n * factorial(\$n - 1);
    }
}
\$factorial = factorial(100000);

// Generate a large file
\$file = fopen('example.txt', 'w');
if (\$file !== false) {
    for (\$i = 0; \$i < 100000; \$i++) {
        fwrite(\$file, str_repeat('x', 1024 * 10) . "\n");
    }
    fclose(\$file);
    echo "Done.";
} else {
    echo "Failed to open file.";
}
EOF

# Set file permissions
sudo chmod 644 "${SCRIPT_FILE}"
sudo chown apache:apache "${SCRIPT_FILE}"


# Run a benchmark testing to load on server to that will fill all max_children limit
#sudo ab -n 1000 -c 50 http://examplethree.com/resource_testing.php >/dev/null

# Start a screen session in background with following benchmark command "ab -n 1000 -c 10 http://examplethree.com/"
screen -d -m ab -n 1000 -c 50 http://examplethree.com/resource_testing.php >/dev/null

echo "Hey it's taking some time to setup the Lab, Hold On Please!"
sleep 45

# Check Apache error log for MaxRequestWorkers error
if grep -q "server reached MaxRequestWorkers setting" /var/log/httpd/error_log; then
    echo "Setup correctly, Lab Setup is complete"
else
    echo "Lab Setup has some issue, Please check manually"
fi

