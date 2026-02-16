FROM debian:bookworm

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        mariadb-client \
        php-fpm \
        php-mysql \
        php-redis \
        php-curl \
        php-gd \
        php-intl \
        php-mbstring \
        php-soap \
        php-xml \
        php-zip \
    && rm -rf /var/lib/apt/lists/*

RUN sed -i 's|listen = /run/php/php8.2-fpm.sock|listen = 9000|' /etc/php/8.2/fpm/pool.d/www.conf \
    && sed -i 's/^;*clear_env = .*/clear_env = no/' /etc/php/8.2/fpm/pool.d/www.conf \
    && sed -i 's/;daemonize = yes/daemonize = no/' /etc/php/8.2/fpm/php-fpm.conf

WORKDIR /var/www/html

RUN curl -fsSL -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

COPY conf/wp-config.php /usr/src/wp-config.php
COPY tools/setup.sh /usr/local/bin/wp-setup.sh
RUN chmod +x /usr/local/bin/wp-setup.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/wp-setup.sh"]
