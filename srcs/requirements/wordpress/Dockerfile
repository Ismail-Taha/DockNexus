FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        php-fpm \
        php-mysql \
        php-cli \
        curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

COPY tools/ /usr/local/bin/

RUN chmod +x /usr/local/bin/*.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/wp-entrypoint.sh"]
