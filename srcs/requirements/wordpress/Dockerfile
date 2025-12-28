FROM debian:bookworm

# Install system dependencies
RUN apt update && apt install -y \
    php-fpm \
    php-mysql \
    php-curl \
    php-gd \
    php-intl \
    php-mbstring \
    php-soap \
    php-xml \
    php-zip \
    curl \
    wget \
    tar \
    mariadb-client \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

# WordPress directory
WORKDIR /var/www/html

# Download and extract WordPress
RUN wget https://wordpress.org/latest.tar.gz \
 && tar -xzf latest.tar.gz \
 && rm latest.tar.gz \
 && mv wordpress/* . \
 && rm -rf wordpress

# Copy your manual wp-config.php (keep a template for volume population)
COPY conf/wp-config.php /var/www/html/wp-config.php
COPY conf/wp-config.php /usr/src/wp-config.php

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
 && chmod +x wp-cli.phar \
 && mv wp-cli.phar /usr/local/bin/wp

# Keep a pristine copy of WordPress to re-seed bind-mounted volumes
RUN cp -a /var/www/html /usr/src/wordpress

# Prepare PHP-FPM
RUN mkdir -p /run/php \
 && sed -i 's|listen = /run/php/php8.2-fpm.sock|listen = 9000|' /etc/php/8.2/fpm/pool.d/www.conf \
 && sed -i 's/;clear_env = no/clear_env = no/' /etc/php/8.2/fpm/pool.d/www.conf

# Copy setup script (to install users)
COPY tools/setup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/setup.sh"]
CMD ["php-fpm8.2", "-F"]
