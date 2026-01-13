#!/bin/bash
set -eu

DATA_DIR="/var/lib/mysql"
SOCKET="/run/mysqld/mysqld.sock"

read_secret_or_env() {
    secret_path="$1"
    env_var_name="$2"

    if [ -f "$secret_path" ]; then
        cat "$secret_path"
        return 0
    fi

    if [ -n "${!env_var_name:-}" ]; then
        echo "Warning: ${secret_path} missing, using ${env_var_name} env var instead." >&2
        printf '%s' "${!env_var_name}"
        return 0
    fi

    echo "Error: ${secret_path} missing and ${env_var_name} is not set." >&2
    exit 1
}

DB_PASSWORD="$(read_secret_or_env /run/secrets/db_password MYSQL_PASSWORD)"
DB_ROOT_PASSWORD="$(read_secret_or_env /run/secrets/db_root_password MYSQL_ROOT_PASSWORD)"

# Force clients to use the local socket even if MYSQL_HOST is set
mysql_sock() {
    MYSQL_HOST= MYSQL_TCP_PORT= mariadb --protocol=socket --socket="$SOCKET" "$@"
}

mysqladmin_sock() {
    MYSQL_HOST= MYSQL_TCP_PORT= mariadb-admin --protocol=socket --socket="$SOCKET" "$@"
}

echo "Starting MariaDB..."

# Prepare runtime directories
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
chown -R mysql:mysql "$DATA_DIR"

# First-time initialization only
if [ ! -d "$DATA_DIR/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    mariadb-install-db --user=mysql --datadir="$DATA_DIR"

    echo "Starting temporary MariaDB server..."
    mysqld --user=mysql --skip-networking --socket="$SOCKET" &
    pid="$!"

    echo "Waiting for MariaDB to be ready..."
    until mysqladmin_sock ping --silent; do
        sleep 1
    done

    echo "Configuring database and users..."
    mysql_sock -uroot <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

    echo "Shutting down temporary MariaDB server..."
    mysqladmin_sock -uroot -p"${DB_ROOT_PASSWORD}" shutdown
    wait "$pid"
else
    echo "Starting temporary MariaDB server to refresh user credentials..."
    mysqld --user=mysql --skip-networking --socket="$SOCKET" &
    pid="$!"

    echo "Waiting for MariaDB to be ready..."
    until mysqladmin_sock ping --silent; do
        sleep 1
    done

    echo "Ensuring database and user exist..."
    if ! mysql_sock -uroot -p"${DB_ROOT_PASSWORD}" <<EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%';
ALTER USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF
    then
        echo "Failed to update user password. Check that secrets/db_root_password.txt matches the DB root password, or reset the data volume." >&2
        mysqladmin_sock -uroot -p"${DB_ROOT_PASSWORD}" shutdown || true
        exit 1
    fi

    echo "Shutting down temporary MariaDB server..."
    mysqladmin_sock -uroot -p"${DB_ROOT_PASSWORD}" shutdown
    wait "$pid"
fi

echo "Starting MariaDB in foreground..."
exec mysqld --user=mysql --datadir="$DATA_DIR"
