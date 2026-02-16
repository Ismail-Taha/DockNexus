FROM debian:bookworm

RUN apt-get update && apt-get install -y nginx && mkdir -p /var/www/html

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/index.html /var/www/html/index.html

EXPOSE 8081

ENTRYPOINT ["nginx", "-g", "daemon off;"]
