#!/bin/bash
set -e

# Wait for MariaDB to be ready
until mysqladmin ping -h"$MYSQL_HOST" --silent; do
  echo "Waiting for MariaDB..."
  sleep 3
done

# If WordPress is not installed, install it
if ! wp core is-installed --allow-root --path=/var/www/html; then

  # Install WordPress core using existing wp-config.php
  wp core install \
    --url="https://${DOMAIN_NAME}" \
    --title="Inception Site" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="$(cat /run/secrets/wp_admin_password)" \
    --admin_email="${WP_ADMIN_EMAIL}" \
    --skip-email \
    --allow-root \
    --path=/var/www/html

  # Create second non-admin user
  wp user create "${WP_USER2}" "${WP_USER2_EMAIL}" \
    --role=subscriber \
    --user_pass="$(cat /run/secrets/wp_user2_password)" \
    --allow-root \
    --path=/var/www/html
fi

exec php-fpm8.2 -F
