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

escape_sed() {
  printf '%s' "$1" | sed -e 's/[\/&]/\\&/g'
}

if [ ! -f "$WP_PATH/wp-includes/version.php" ] || [ ! -f "$WP_PATH/wp-settings.php" ] || [ ! -f "$WP_PATH/index.php" ]; then
  echo "WordPress core files missing/incomplete. Downloading core files..."
  wp core download --allow-root --path="$WP_PATH" --force
fi

if [ -f /usr/src/wp-config.php ]; then
  DB_NAME_ESC="$(escape_sed "${MYSQL_DATABASE:-}")"
  DB_USER_ESC="$(escape_sed "${MYSQL_USER:-}")"
  DB_PASS_ESC="$(escape_sed "$DB_PASSWORD")"
  DOMAIN_ESC="$(escape_sed "${DOMAIN_NAME:-localhost}")"
  REDIS_HOST_ESC="$(escape_sed "${REDIS_HOST:-redis}")"

  sed \
    -e "s/__DB_NAME__/$DB_NAME_ESC/g" \
    -e "s/__DB_USER__/$DB_USER_ESC/g" \
    -e "s/__DB_PASSWORD__/$DB_PASS_ESC/g" \
    -e "s/__DOMAIN_NAME__/$DOMAIN_ESC/g" \
    -e "s/__REDIS_HOST__/$REDIS_HOST_ESC/g" \
    /usr/src/wp-config.php > "$WP_PATH/wp-config.php"
fi

# MariaDB is guaranteed to be ready due to healthcheck
# Just verify the connection works
echo "Verifying MariaDB connection..."
if ! mysql -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$DB_PASSWORD" -e "SELECT 1;" >/dev/null 2>&1; then
  echo "Error: Cannot connect to MariaDB" >&2
  exit 1
fi
echo "MariaDB connection verified."

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

# Fix permissions - SHARED OWNERSHIP FOR FTP
WP_CONTENT="$WP_PATH/wp-content"
UPLOADS_DIR="$WP_CONTENT/uploads"

mkdir -p "$WP_CONTENT"

# Set ownership to www-data but make group-writable for FTP
chown -R www-data:www-data "$WP_CONTENT"

# Make uploads directory group-writable (775) so FTP can write
if [ -d "$UPLOADS_DIR" ]; then
  chmod 775 "$UPLOADS_DIR"
  find "$UPLOADS_DIR" -type d -exec chmod 775 {} \;
  find "$UPLOADS_DIR" -type f -exec chmod 664 {} \;
fi

# Keep other wp-content subdirectories safer (755)
find "$WP_CONTENT" -type d ! -path "$UPLOADS_DIR*" -exec chmod 755 {} \;
find "$WP_CONTENT" -type f ! -path "$UPLOADS_DIR*" -exec chmod 644 {} \;

mkdir -p /run/php
exec php-fpm8.2 -F
