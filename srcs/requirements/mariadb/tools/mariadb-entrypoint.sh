#!/bin/bash
set -eu

DATA_DIR="/var/lib/mysql"
SOCKET="/run/mysqld/mysqld.sock"

DB_PASSWORD="$(cat /run/secrets/db_password)"
DB_ROOT_PASSWORD="$(cat /run/secrets/db_root_password)"

: "${MYSQL_DATABASE:?MYSQL_DATABASE is required}"
: "${MYSQL_USER:?MYSQL_USER is required}"
: "${DB_PASSWORD:?db_password is empty}"
: "${DB_ROOT_PASSWORD:?db_root_password is empty}"

echo "Preparing MariaDB directories..."
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
chown -R mysql:mysql "$DATA_DIR"

if [ ! -d "$DATA_DIR/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    mariadb-install-db --user=mysql --datadir="$DATA_DIR"

    echo "Bootstrapping database and users..."
    mariadbd --user=mysql --datadir="$DATA_DIR" --socket="$SOCKET" --bootstrap <<EOF
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF
    echo "Bootstrap complete."
else
    echo "Existing database detected; skipping bootstrap."
fi

echo "Starting MariaDB in foreground..."
exec mariadbd --user=mysql --datadir="$DATA_DIR" --socket="$SOCKET" --console
