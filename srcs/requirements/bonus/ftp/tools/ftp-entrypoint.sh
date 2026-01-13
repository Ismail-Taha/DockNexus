#!/bin/sh
set -eu

adduser -D -h /var/www/html "${FTP_USER:-wpftp}"
echo "${FTP_USER:-wpftp}:${FTP_PASSWORD:-changeme}" | chpasswd

exec vsftpd /etc/vsftpd/vsftpd.conf
