#!/bin/bash
set -eu

# Ensure vsftpd secure chroot directory exists
mkdir -p /var/run/vsftpd/empty

: "${FTP_USER:?FTP_USER is required}"
: "${FTP_PASSWORD:?FTP_PASSWORD is required}"

UPLOADS_DIR="/var/www/html/wp-content/uploads"

# Create www-data group (same GID as Debian WordPress container)
if ! getent group www-data >/dev/null 2>&1; then
  addgroup --gid 33 www-data
fi

# Create FTP user if doesn't exist
if ! id -u "$FTP_USER" >/dev/null 2>&1; then
  adduser --disabled-password --home /var/www/html --gecos "" "$FTP_USER"
fi

# Add FTP user to www-data group
adduser "$FTP_USER" www-data

# Set password
echo "${FTP_USER}:${FTP_PASSWORD}" | chpasswd

# WordPress is guaranteed to be ready due to healthcheck
# Just ensure uploads directory exists
mkdir -p "$UPLOADS_DIR"

# Set group ownership to www-data, make group-writable
chown -R 33:33 "$UPLOADS_DIR"
chmod -R 775 "$UPLOADS_DIR"

echo "FTP directory permissions set:"
ls -la /var/www/html/wp-content/
ls -la "$UPLOADS_DIR"

exec vsftpd /etc/vsftpd/vsftpd.conf