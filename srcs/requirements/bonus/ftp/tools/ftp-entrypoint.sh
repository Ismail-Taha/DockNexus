#!/bin/sh
set -eu

: "${FTP_USER:?FTP_USER is required}"
: "${FTP_PASSWORD:?FTP_PASSWORD is required}"
UPLOADS_DIR="/var/www/html/wp-content/uploads"

if ! id -u "$FTP_USER" >/dev/null 2>&1; then
  adduser -D -h /var/www/html "$FTP_USER"
fi
echo "${FTP_USER}:${FTP_PASSWORD}" | chpasswd

# Ensure upload path exists and is writable from both FTP and WordPress containers.
# This avoids UID/GID mismatch issues across Debian (wordpress) and Alpine (ftp).
mkdir -p "$UPLOADS_DIR"
chmod 777 "$UPLOADS_DIR"

exec vsftpd /etc/vsftpd/vsftpd.conf
