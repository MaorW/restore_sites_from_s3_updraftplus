#!/bin/bash

# For Updraftplus premium upload
echo "php_value upload_max_filesize 12M" >> /var/www/html/.htaccess

## Preperation for the restore script  ##

# AWS CLI Install
apt-get update && apt-get install -y awscli unzip wget

# WP CLI Install
wget -O wp-cli.phar https://raw.github.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Mariadb cli install
apt update && apt install -y mariadb-server && service mariadb start