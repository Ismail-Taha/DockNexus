#!/bin/bash
set -e

WP_PATH="/var/www/html"

DB_PASSWORD="$(cat /run/secrets/db_password)"
if [ -z "$DB_PASSWORD" ]; then
  echo "Error: /run/secrets/db_password is empty." >&2
  exit 1
fi

: "${WP_ADMIN_PASSWORD:?WP_ADMIN_PASSWORD is required}"
: "${WP_USER2_PASSWORD:?WP_USER2_PASSWORD is required}"

mkdir -p "$WP_PATH"
cd "$WP_PATH"

if [ ! -f "$WP_PATH/wp-includes/version.php" ] || [ ! -f "$WP_PATH/wp-settings.php" ] || [ ! -f "$WP_PATH/index.php" ]; then
  echo "WordPress core files missing/incomplete. Downloading core files..."
  wp core download --allow-root --path="$WP_PATH" --force
fi

if [ ! -f "$WP_PATH/wp-config.php" ] && [ -f /usr/src/wp-config.php ]; then
  cp /usr/src/wp-config.php "$WP_PATH/wp-config.php"
fi

echo "Waiting for MariaDB..."
until mysql -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$DB_PASSWORD" -e "SELECT 1;" >/dev/null 2>&1; do
  echo "MariaDB is not ready yet..."
  sleep 2
done
echo "MariaDB is ready."

if ! wp core is-installed --allow-root --path="$WP_PATH"; then
  wp core install \
    --url="https://${DOMAIN_NAME}" \
    --title="Inception Site" \
    --admin_user="$WP_ADMIN_USER" \
    --admin_password="$WP_ADMIN_PASSWORD" \
    --admin_email="$WP_ADMIN_EMAIL" \
    --skip-email \
    --allow-root \
    --path="$WP_PATH"

  wp user create \
    "$WP_USER2" "$WP_USER2_EMAIL" \
    --user_pass="$WP_USER2_PASSWORD" \
    --role=subscriber \
    --allow-root \
    --path="$WP_PATH"
fi

if [ -n "${REDIS_HOST:-}" ]; then
  wp plugin install redis-cache --activate --allow-root --path="$WP_PATH" || true
  wp redis enable --allow-root --path="$WP_PATH" || true
fi

# Fix permissions so PHP-FPM can write to wp-content
WP_CONTENT="$WP_PATH/wp-content"
mkdir -p "$WP_CONTENT"
chown -R www-data:www-data "$WP_CONTENT"
find "$WP_CONTENT" -type d -exec chmod 755 {} \;
find "$WP_CONTENT" -type f -exec chmod 644 {} \;

mkdir -p /run/php
exec php-fpm8.2 -F
