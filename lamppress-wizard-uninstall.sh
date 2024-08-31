#!/bin/bash

echo "LampPress Wizard Uninstall Script"
echo "This script will remove WordPress, LAMP stack, and revert security changes."
echo "WARNING: This will delete all your WordPress files and database!"
read -p "Are you sure you want to proceed? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Uninstall cancelled."
    exit 1
fi

# Function to remove a package if it's installed
remove_if_installed() {
    if dpkg -s "$1" >/dev/null 2>&1; then
        sudo apt-get remove --purge -y "$1"
    fi
}

# Remove WordPress files
sudo rm -rf /var/www/html/*

# Remove Apache, PHP, and MySQL
remove_if_installed apache2
remove_if_installed php
remove_if_installed mysql-server
remove_if_installed mariadb-server

# Remove PHP modules
sudo apt-get remove --purge -y php*

# Remove Fail2ban
remove_if_installed fail2ban

# Disable and remove UFW
sudo ufw disable
remove_if_installed ufw

# Remove remaining dependencies
sudo apt-get autoremove -y

# Remove MySQL databases
echo "Removing MySQL databases..."
sudo mysql -e "DROP DATABASE IF EXISTS wordpress;"
sudo mysql -e "DROP USER IF EXISTS 'wordpressuser'@'localhost';"

# Remove configuration files
sudo rm -f /etc/apache2/sites-available/wordpress.conf
sudo rm -f /etc/php/*/apache2/php.ini
sudo rm -f /etc/mysql/my.cnf

# Revert system changes
sudo sed -i 's/ServerTokens Prod/ServerTokens OS/' /etc/apache2/conf-available/security.conf
sudo sed -i 's/ServerSignature Off/ServerSignature On/' /etc/apache2/conf-available/security.conf
sudo sed -i 's/TraceEnable Off/TraceEnable On/' /etc/apache2/conf-available/security.conf

# Remove Fail2ban configuration
sudo rm -f /etc/fail2ban/jail.local

echo "LampPress Wizard has been uninstalled."
echo "Note: Some system configurations may still remain. Please review your system settings."
echo "You may need to reboot your Raspberry Pi to complete the uninstallation process."
