#!/bin/bash
set -e

WP_PATH="/var/www/html"

mkdir -p "$WP_PATH"
cd "$WP_PATH"

if ! command -v wp >/dev/null 2>&1; then
  curl -o /tmp/wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
  chmod +x /tmp/wp-cli.phar
  mv /tmp/wp-cli.phar /usr/local/bin/wp
fi

if [ ! -f "$WP_PATH/wp-includes/version.php" ]; then
  wp core download --allow-root
fi

if [ ! -f "$WP_PATH/wp-config.php" ] && [ -f /usr/src/wp-config.php ]; then
  cp /usr/src/wp-config.php "$WP_PATH/wp-config.php"
fi

echo "Waiting for MariaDB..."
until mysql -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$(cat /run/secrets/db_password)" -e "SELECT 1;" >/dev/null 2>&1; do
  echo "MariaDB is not ready yet..."
  sleep 2
done
echo "MariaDB is ready."

if ! wp core is-installed --allow-root --path="$WP_PATH"; then
  wp core install \
    --url="https://${DOMAIN_NAME}" \
    --title="Inception Site" \
    --admin_user="$WP_ADMIN_USER" \
    --admin_password="$(cat /run/secrets/wp_admin_password)" \
    --admin_email="$WP_ADMIN_EMAIL" \
    --skip-email \
    --allow-root \
    --path="$WP_PATH"

  wp user create \
    "$WP_USER2" "$WP_USER2_EMAIL" \
    --user_pass="$(cat /run/secrets/wp_user2_password)" \
    --role=subscriber \
    --allow-root \
    --path="$WP_PATH"
fi

if [ -n "${REDIS_HOST:-}" ]; then
  wp plugin install redis-cache --activate --allow-root --path="$WP_PATH" || true
  wp redis enable --allow-root --path="$WP_PATH" || true
fi

mkdir -p /run/php
exec php-fpm8.2 -F
