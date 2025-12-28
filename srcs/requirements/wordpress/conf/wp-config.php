<?php
define( 'DB_NAME', getenv('MYSQL_DATABASE') );
define( 'DB_USER', getenv('MYSQL_USER') );
define( 'DB_PASSWORD', getenv('MYSQL_PASSWORD') );
define( 'DB_HOST', 'mariadb:3306' );
define( 'WP_HOME', 'https://' . getenv('DOMAIN_NAME') );
define( 'WP_SITEURL', 'https://' . getenv('DOMAIN_NAME') );
define( 'FS_METHOD', 'direct' );
// salts : Ces clés de sécurités rendent le site plus difficilement attaquables
// en ajoutant des éléments aléatoires aux mots de passes.
define('AUTH_KEY',         '}+[*ofk[m0k&Yho%DA^ORA3kjQ_EI|Y@0lHS/2|Xe4|1jz_I&MfW<.ey-8%qo7JL');
define('SECURE_AUTH_KEY',  'z>U=f8#3-Fu7-~Id3|h<Z>%n{|2*(@?h6 ;o*vUy$bkbuzHSS_^pK+l<URqG*$5`');
define('LOGGED_IN_KEY',    'oO/,OkQiC=4z|Z+mhx;P):-g19G:hO|+]gk`-QSV;Xr^{l&*SPX.w1<f1-l]IVw8');
define('NONCE_KEY',        'cuD}V[NE+ag5~:0> $~).J`tmxnIs$-j1?]2AY:6;M@||G*;b^G0qT3AA_qpC.]U');
define('AUTH_SALT',        ' o]][5,}y4]M4B}32F^C -o[TGA~qHp$K5 h!fTR6$qP$DW$Y,EUIgB[rRGcHU?0');
define('SECURE_AUTH_SALT', 'roQTU;0#?0!1Km=.Mj5.|s-nP%!Y| GA^cSXCZvS}|EtF{`~RT;bFGpM?-N1)q1V');
define('LOGGED_IN_SALT',   '+%]UA~u9+`Y+*1cdsc )JUdwbi=g?=V,M`@>3tl/O]]:`2gZz6Cq6lka6C&/}M!J');
define('NONCE_SALT',       'v?_CM~vY@)XKlk+5r;k(Gv*|4hvI~-;Go}R6ci![BM(ml8[0Rt[98=|&zC$/]xCM');

$table_prefix = 'wp_';
if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', __DIR__ . '/' );
}
require_once ABSPATH . 'wp-settings.php';
