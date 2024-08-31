# LampPress Wizard

LampPress Wizard is a bash script that automates the installation of a secure LAMP (Linux, Apache, MySQL, PHP) stack and WordPress on a Raspberry Pi running Raspberry Pi OS Bookworm. The script includes various security enhancements to protect your installation from common threats.

## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Security Features](#security-features)
- [Post-Installation Security](#post-installation-security)
- [Contributing](#contributing)
- [License](#license)

## Features

- One-click installation of Apache, MySQL (MariaDB), PHP, and WordPress
- Secure MySQL setup with automatic strong password generation
- User-friendly prompts for database customization
- Implementation of various security measures out-of-the-box
- Tailored for Raspberry Pi OS Bookworm

## Prerequisites

- A Raspberry Pi running Raspberry Pi OS Bookworm
- Internet connection
- Sudo privileges

## Installation

1. Clone this repository:
   ```
   git clone https://github.com/yourusername/lamppress-wizard.git
   ```
2. Navigate to the repository directory:
   ```
   cd lamppress-wizard
   ```
3. Make the script executable:
   ```
   chmod +x lamppress_wizard.sh
   ```

## Usage

1. Run the script with sudo privileges:
   ```
   sudo ./lamppress_wizard.sh
   ```
2. Follow the prompts to enter your desired database name and username.
3. When the script completes, save the displayed database credentials.
4. Access your WordPress installation by navigating to your Raspberry Pi's IP address in a web browser.

## Uninstallation

If you need to remove LampPress Wizard and all associated components:

1. Run the uninstall script with sudo privileges:
   ```
   sudo ./uninstall_lamppress_wizard.sh
   ```
2. Confirm that you want to proceed with the uninstallation when prompted.

**Warning:** The uninstall script will remove WordPress, the LAMP stack, and revert security changes. All your WordPress files and database will be deleted. Make sure to backup any important data before running the uninstall script.

## Security Features

LampPress Wizard implements the following security measures:

1. Firewall (UFW) configuration:
   - Denies all incoming connections by default
   - Allows SSH, HTTP (80), and HTTPS (443) connections

2. Fail2ban installation and configuration:
   - Protects against brute-force attacks
   - Bans IP addresses after 3 failed attempts for 1 hour

3. Apache security enhancements:
   - Disables server tokens and signatures
   - Enables security-related Apache modules

4. Secure file permissions:
   - Sets stricter permissions on WordPress files and directories

5. WordPress security improvements:
   - Disables file editing from the WordPress admin
   - Enables automatic updates for minor releases
   - Creates a .htaccess file with security rules

6. Strong password generation for the database

## Post-Installation Security

After installation, consider these additional security measures:

1. Install and configure a WordPress security plugin
2. Implement SSL/TLS encryption (HTTPS)
3. Regularly update your system and WordPress installation
4. Use strong passwords for all accounts
5. Implement regular backups of your website and database
6. Monitor your site for suspicious activity

For more detailed security recommendations, please refer to the [SECURITY.md](SECURITY.md) file.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
