#!/bin/bash
set -eu

WP_PATH="/var/www/html"

: "${MYSQL_HOST:?MYSQL_HOST is required}"
: "${MYSQL_DATABASE:?MYSQL_DATABASE is required}"
: "${MYSQL_USER:?MYSQL_USER is required}"
: "${MYSQL_PASSWORD:?MYSQL_PASSWORD is required}"
: "${DOMAIN_NAME:?DOMAIN_NAME is required}"
: "${WP_ADMIN_USER:?WP_ADMIN_USER is required}"
: "${WP_ADMIN_PASSWORD:?WP_ADMIN_PASSWORD is required}"
: "${WP_ADMIN_EMAIL:?WP_ADMIN_EMAIL is required}"
: "${WP_USER2:?WP_USER2 is required}"
: "${WP_USER2_PASSWORD:?WP_USER2_PASSWORD is required}"
: "${WP_USER2_EMAIL:?WP_USER2_EMAIL is required}"

mkdir -p "$WP_PATH"
cd "$WP_PATH"

if [ ! -f "$WP_PATH/wp-load.php" ]; then
  wp core download --allow-root --path="$WP_PATH"
fi

if [ ! -f "$WP_PATH/wp-config.php" ] && [ -f /usr/src/wp-config.php ]; then
  cp /usr/src/wp-config.php "$WP_PATH/wp-config.php"
fi

until mysql -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SELECT 1;" >/dev/null 2>&1; do
  sleep 2
done

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
  wp plugin is-installed redis-cache --allow-root --path="$WP_PATH" \
    || wp plugin install redis-cache --activate --allow-root --path="$WP_PATH"
  wp redis enable --allow-root --path="$WP_PATH" || true
fi

WP_CONTENT="$WP_PATH/wp-content"
UPLOADS_DIR="$WP_CONTENT/uploads"

mkdir -p "$UPLOADS_DIR"
chown -R www-data:www-data "$WP_CONTENT"
chmod 775 "$UPLOADS_DIR"
find "$UPLOADS_DIR" -type d -exec chmod 775 {} \;
find "$UPLOADS_DIR" -type f -exec chmod 664 {} \;

mkdir -p /run/php
exec php-fpm8.2 -F
