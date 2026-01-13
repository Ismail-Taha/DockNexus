<?php
define('DB_NAME', getenv('MYSQL_DATABASE'));
define('DB_USER', getenv('MYSQL_USER'));

/**
 * Read DB password from Docker secret (recommended).
 * Make sure docker-compose mounts the secret as /run/secrets/db_password
 */
define('DB_PASSWORD', getenv('MYSQL_PASSWORD'));

define('DB_HOST', 'mariadb:3306');

define('WP_HOME', 'https://' . getenv('DOMAIN_NAME'));
define('WP_SITEURL', 'https://' . getenv('DOMAIN_NAME'));

define('FS_METHOD', 'direct');

define('WP_REDIS_HOST', getenv('REDIS_HOST') ?: 'redis');
define('WP_REDIS_PORT', 6379);

define('AUTH_KEY',         'cUu: (,;+%T+ Z:-Sx8|;XVNI[${3gB8$65YO0Sx.oCw@T#L)+]p=ccJZax^ngX-');
define('SECURE_AUTH_KEY',  ',V7+f=bK vVr o2a0UAO30 U4Ao_`S3-qtu^kK&1j%<9$+4H9:jag3ksFfXU$iOI');
define('LOGGED_IN_KEY',    'IO|GoY*.9{NMDEnpRLmWFkZoMV^_V@-+Q$CyEg4$?sTk,L@;o?]!Ve4)QfcKq(o4');
define('NONCE_KEY',        '+[wAw+!D5[0-->s46$jbu`JAQDuh=,>N^Ph4#;bp{3:bLZBO~r?Kr)^k>-/LPE+F');
define('AUTH_SALT',        '>(jX[( DBh>-~#o=FT{,`0/!v(Qz3(|je-5,Ky_4Tz7W.V1<E$h&-6,}%m(L)owH');
define('SECURE_AUTH_SALT', 'MU!.-7$beWxoEV,1N:RL<jSXn!;Q3?k)Ch8SYT!lG]:_9+_:.&pwas77TD_`K#s_');
define('LOGGED_IN_SALT',   '8#|F]<r|8IlD+w+;/qIBBz+x24/~=w9N~4K_PD1e;?6MSrDXvqcbD(S[xYB-n/5-');
define('NONCE_SALT',       'q9o^upz=O nv$q(l%q=[<?~BT-[m(wh(r@T=.DV|SgOuWlik%h-J&gkFGcCG5*ky');

$table_prefix = 'wp_';

if (!defined('ABSPATH')) {
    define('ABSPATH', __DIR__ . '/');
}
require_once ABSPATH . 'wp-settings.php';
