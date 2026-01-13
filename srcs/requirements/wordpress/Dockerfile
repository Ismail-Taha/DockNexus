FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    wget \
    tar \
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

# PHP-FPM: listen on TCP 9000 (for nginx fastcgi_pass)
RUN sed -i 's|listen = /run/php/php8.2-fpm.sock|listen = 9000|' /etc/php/8.2/fpm/pool.d/www.conf \
 && sed -i 's/;clear_env = no/clear_env = no/' /etc/php/8.2/fpm/pool.d/www.conf \
 && mkdir -p /run/php

WORKDIR /var/www/html

# Install WordPress core at build time
RUN wget https://wordpress.org/latest.tar.gz \
 && tar -xzf latest.tar.gz \
 && rm latest.tar.gz \
 && mv wordpress/* . \
 && rm -rf wordpress

# Install WP-CLI at build time
RUN curl -fsSL -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
 && chmod +x /usr/local/bin/wp

# Copy config template + your setup script
COPY conf/wp-config.php /usr/src/wp-config.php
COPY tools/setup.sh /usr/local/bin/wp-setup.sh
RUN chmod +x /usr/local/bin/wp-setup.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/wp-setup.sh"]
