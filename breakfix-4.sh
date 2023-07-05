#!/bin/bash
read -p "Do you want to install Apache? (y/n) " answer

if [[ $answer = y ]]; then
    # Install Apache
    sudo dnf install httpd -y


else
    echo "Apache installation skipped and proceeding for setting up Breakfix lab."
fi

#Removing Apache dependency packahe "mailcap"
sudo rpm -e --nodeps mailcap

# Change apache service file
#    if sudo sed -i '/-DFOREGROUND/s/$/ hello/' /usr/lib/systemd/system/httpd.service; then
#        # Reload daemon
#        sudo systemctl daemon-reload
#        echo	
#        echo "Break Fix Lab setup is successful."
#    else
#        echo "Failed to add lines to httpd.conf"
#    fi
