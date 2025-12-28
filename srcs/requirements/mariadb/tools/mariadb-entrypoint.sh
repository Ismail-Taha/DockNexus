#!/bin/sh
set -eu

DATA_DIR="/var/lib/mysql"

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
chown -R mysql:mysql "$DATA_DIR"

# Initialize MariaDB data directory and seed default database/user on first run
if [ ! -d "$DATA_DIR/mysql" ]; then
    mariadb-install-db --user=mysql --ldata="$DATA_DIR"

    mysqld --user=mysql --skip-networking --socket=/run/mysqld/mysqld.sock &
    pid="$!"

    until mariadb-admin ping --silent; do
        sleep 1
    done

    mysql <<SQL
-- Secure root account if password provided
$( [ -n "${MYSQL_ROOT_PASSWORD:-}" ] && echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';" )
$( [ -n "${MYSQL_ROOT_PASSWORD:-}" ] && echo "ALTER USER 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';" )
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
SQL

    mysqladmin shutdown
    wait "$pid"
fi

exec mysqld --user=mysql --datadir="$DATA_DIR" --bind-address=0.0.0.0
