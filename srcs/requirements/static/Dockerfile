FROM alpine:3.19

RUN apk add --no-cache nginx && mkdir -p /var/www/html

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/index.html /var/www/html/index.html

EXPOSE 8081

ENTRYPOINT ["nginx", "-g", "daemon off;"]
