#!/bin/sh
set -eu

if [ ! -f wp-config.php ]; then
    cat <<'EOF' > wp-config.php
<?php
define( 'DB_NAME', getenv('MYSQL_DATABASE') );
define( 'DB_USER', getenv('MYSQL_USER') );
define( 'DB_PASSWORD', getenv('MYSQL_PASSWORD') );
define( 'DB_HOST', 'mariadb:3306' );
define( 'WP_HOME', 'https://' . getenv('DOMAIN_NAME') );
define( 'WP_SITEURL', 'https://' . getenv('DOMAIN_NAME') );
define( 'FS_METHOD', 'direct' );
$table_prefix = 'wp_';
if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', __DIR__ . '/' );
}
require_once ABSPATH . 'wp-settings.php';
EOF
fi

exec php-fpm -F
