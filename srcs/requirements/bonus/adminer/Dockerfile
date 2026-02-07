FROM alpine:3.22.3

RUN apk add --no-cache php82 php82-session php82-pdo_mysql curl \
    && mkdir -p /var/www/html \
    && curl -fsSL https://www.adminer.org/latest.php -o /var/www/html/index.php

WORKDIR /var/www/html

EXPOSE 8082

ENTRYPOINT ["php82", "-S", "0.0.0.0:8082"]
