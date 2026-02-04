#!/bin/sh
set -eu

FTP_USER="${FTP_USER:-wpftp}"
FTP_PASSWORD="${FTP_PASSWORD:-changeme}"

if ! id -u "$FTP_USER" >/dev/null 2>&1; then
  adduser -D -h /var/www/html "$FTP_USER"
fi
echo "${FTP_USER}:${FTP_PASSWORD}" | chpasswd

exec vsftpd /etc/vsftpd/vsftpd.conf
