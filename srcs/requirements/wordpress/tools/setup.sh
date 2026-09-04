#!/bin/bash
set -e

DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(grep '^wp_admin_password=' /run/secrets/credentials | cut -d '=' -f2-)
WP_USER_PASSWORD=$(grep '^wp_user_password=' /run/secrets/credentials | cut -d '=' -f2-)

mkdir -p /var/www/html
cd /var/www/html

if [ ! -f /var/www/html/wp-config.php ]; then

    # 1. Download WordPress core (only the files)
    wp core download --allow-root --path=/var/www/html

    # 2. Generate wp-config.php
    wp config create \
        --allow-root \
        --path=/var/www/html \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${DB_PASSWORD}" \
        --dbhost="mariadb:3306" \
        --skip-check

    # 3. Install WordPress (creates the first user).
    wp core install \
        --allow-root \
        --path=/var/www/html \
        --url="${WP_URL}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email

    # 4. Create the second
    wp user create \
        --allow-root \
        --path=/var/www/html \
        "${WP_USER}" "${WP_USER_EMAIL}" \
        --role="${WP_USER_ROLE}" \
        --user_pass="${WP_USER_PASSWORD}"

    chown -R www-data:www-data /var/www/html
    find /var/www/html -type d -exec chmod 755 {} \;
    find /var/www/html -type f -exec chmod 644 {} \;
fi

exec php-fpm8.2 -F
