#!/bin/bash

echo "Welcome to LampPress Wizard!"
echo "This script will install a secure LAMP stack and WordPress on your Raspberry Pi."

# Function to generate a strong random password
generate_password() {
    openssl rand -base64 16 | tr -d "=+/" | cut -c1-16
}

# Update and upgrade the system
sudo apt update && sudo apt upgrade -y

# Install Apache web server
sudo apt install apache2 -y

# Install MySQL (MariaDB) server
sudo apt install mariadb-server -y

# Install PHP and required modules
sudo apt install php php-mysql php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip -y

# Install additional security-related packages
sudo apt install fail2ban ufw -y

# Configure firewall
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw --force enable

# Configure fail2ban
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo sed -i 's/bantime  = 10m/bantime  = 1h/' /etc/fail2ban/jail.local
sudo sed -i 's/findtime  = 10m/findtime  = 20m/' /etc/fail2ban/jail.local
sudo sed -i 's/maxretry = 5/maxretry = 3/' /etc/fail2ban/jail.local
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Secure Apache
sudo sed -i 's/ServerTokens OS/ServerTokens Prod/' /etc/apache2/conf-available/security.conf
sudo sed -i 's/ServerSignature On/ServerSignature Off/' /etc/apache2/conf-available/security.conf
sudo sed -i 's/TraceEnable On/TraceEnable Off/' /etc/apache2/conf-available/security.conf

# Enable Apache security modules
sudo a2enmod headers
sudo a2enmod rewrite

# Restart Apache
sudo systemctl restart apache2

# Secure MySQL installation
sudo mysql_secure_installation

# Prompt user for database details
read -p "Enter the name for the WordPress database: " DB_NAME
read -p "Enter the username for the WordPress database: " DB_USER
DB_PASS=$(generate_password)

# Create WordPress database and user
sudo mysql -e "CREATE DATABASE ${DB_NAME};"
sudo mysql -e "CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
sudo mysql -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Download and install WordPress
cd /var/www/html
sudo rm index.html
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xzvf latest.tar.gz
sudo mv wordpress/* .
sudo rm -rf wordpress latest.tar.gz

# Set correct permissions
sudo chown -R www-data:www-data /var/www/html
sudo find /var/www/html -type d -exec chmod 750 {} \;
sudo find /var/www/html -type f -exec chmod 640 {} \;

# Create wp-config.php
sudo cp wp-config-sample.php wp-config.php
sudo sed -i "s/database_name_here/${DB_NAME}/" wp-config.php
sudo sed -i "s/username_here/${DB_USER}/" wp-config.php
sudo sed -i "s/password_here/${DB_PASS}/" wp-config.php

# Generate and set security keys
SECURITY_KEYS=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)
sudo sed -i "/AUTH_KEY/d" wp-config.php
sudo sed -i "/SECURE_AUTH_KEY/d" wp-config.php
sudo sed -i "/LOGGED_IN_KEY/d" wp-config.php
sudo sed -i "/NONCE_KEY/d" wp-config.php
sudo sed -i "/AUTH_SALT/d" wp-config.php
sudo sed -i "/SECURE_AUTH_SALT/d" wp-config.php
sudo sed -i "/LOGGED_IN_SALT/d" wp-config.php
sudo sed -i "/NONCE_SALT/d" wp-config.php
echo "${SECURITY_KEYS}" | sudo tee -a wp-config.php > /dev/null

# Add additional security measures to wp-config.php
echo "define('DISALLOW_FILE_EDIT', true);" | sudo tee -a wp-config.php
echo "define('WP_AUTO_UPDATE_CORE', 'minor');" | sudo tee -a wp-config.php

# Create .htaccess file with security rules
cat << EOF | sudo tee /var/www/html/.htaccess
# Disable directory browsing
Options All -Indexes

# Protect wp-config.php
<files wp-config.php>
order allow,deny
deny from all
</files>

# Protect .htaccess
<files .htaccess>
order allow,deny
deny from all
</files>

# Limit file uploads to 5MB
php_value upload_max_filesize 5M
php_value post_max_size 5M

# Disable PHP execution in uploads directory
<Directory /var/www/html/wp-content/uploads>
    php_flag engine off
</Directory>
EOF

echo "LampPress Wizard installation complete!"
echo "WordPress database name: ${DB_NAME}"
echo "WordPress database user: ${DB_USER}"
echo "WordPress database password: ${DB_PASS}"
echo "Please save these credentials and complete the installation by visiting your Raspberry Pi's IP address in a web browser."
echo "Remember to change the default admin username and use a strong password during the WordPress setup."
