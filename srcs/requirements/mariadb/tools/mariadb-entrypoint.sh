#!/bin/sh
set -eu

DATA_DIR="/var/lib/mysql"

if [ ! -d "$DATA_DIR/mysql" ]; then
    mariadb-install-db --user=mysql --ldata="$DATA_DIR"

    mysqld --skip-networking --socket=/run/mysqld/mysqld.sock &
    pid="$!"

    until mariadb-admin ping --silent; do
        sleep 1
    done

    mysql <<-SQL
        CREATE DATABASE IF NOT EXISTS \
            ${MYSQL_DATABASE} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
        FLUSH PRIVILEGES;
    SQL

    mysqladmin shutdown
    wait "$pid"
fi

exec mysqld
