FROM alpine:3.19

RUN apk add --no-cache lighttpd

COPY conf/lighttpd.conf /etc/lighttpd/lighttpd.conf
COPY tools/site/ /var/www/localhost/htdocs/

EXPOSE 8081

ENTRYPOINT ["lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf"]
