FROM alpine:3.22.3

RUN apk add --no-cache vsftpd

COPY conf/vsftpd.conf /etc/vsftpd/vsftpd.conf
COPY tools/ /usr/local/bin/

RUN chmod +x /usr/local/bin/*.sh

EXPOSE 21

ENTRYPOINT ["/usr/local/bin/ftp-entrypoint.sh"]
