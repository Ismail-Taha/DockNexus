#!/bin/bash
set -eu

# Waiting for MariaDB to be ready
until mysqladmin ping -h"$MYSQL_HOST" --silent; do
  echo "Waiting for MariaDB..."
  sleep 3
done

# Populate WordPress files into the bind mount if empty
if [ ! -f /var/www/html/wp-includes/version.php ]; then
  echo "Seeding WordPress files into /var/www/html..."
  cp -a /usr/src/wordpress/. /var/www/html
fi

# Ensure wp-config.php exists (for fresh mounts)
if [ ! -f /var/www/html/wp-config.php ] && [ -f /usr/src/wp-config.php ]; then
  cp /usr/src/wp-config.php /var/www/html/wp-config.php
fi

load_secret_or_env() {
  file_var="$1"
  env_var="$2"
  default_path="$3"

  # Prefer FILE env var, then env var, then default file path
  if [ -n "${!file_var:-}" ] && [ -f "${!file_var}" ]; then
    cat "${!file_var}"
  elif [ -n "${!env_var:-}" ]; then
    printf '%s' "${!env_var}"
  elif [ -f "$default_path" ]; then
    cat "$default_path"
  else
    echo "Missing credentials: set $file_var, $env_var, or provide $default_path" >&2
    exit 1
  fi
}

ADMIN_PASSWORD="$(load_secret_or_env WP_ADMIN_PASSWORD_FILE WP_ADMIN_PASSWORD /run/secrets/wp_admin_password)"
USER2_PASSWORD="$(load_secret_or_env WP_USER2_PASSWORD_FILE WP_USER2_PASSWORD /run/secrets/wp_user2_password)"

# If WordPress is not installed, install it
if ! wp core is-installed --allow-root --path=/var/www/html; then

  # Install WordPress core using existing wp-config.php
  wp core install \
    --url="https://${DOMAIN_NAME}" \
    --title="Inception Site" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${ADMIN_PASSWORD}" \
    --admin_email="${WP_ADMIN_EMAIL}" \
    --skip-email \
    --allow-root \
    --path=/var/www/html

  # Create second non-admin user
  wp user create "${WP_USER2}" "${WP_USER2_EMAIL}" \
    --role=subscriber \
    --user_pass="${USER2_PASSWORD}" \
    --allow-root \
    --path=/var/www/html
fi

exec php-fpm8.2 -F
