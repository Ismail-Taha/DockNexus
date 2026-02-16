FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        php \
        php-cli \
        php-mysql \
        curl \
        tini \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/www/html \
    && curl -fsSL https://www.adminer.org/latest.php -o /var/www/html/index.php

WORKDIR /var/www/html

EXPOSE 8082

ENTRYPOINT ["/usr/bin/tini", "--", "php", "-S", "0.0.0.0:8082"]