FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        vsftpd \
        passwd \
        tini \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/run/vsftpd/empty

COPY conf/vsftpd.conf /etc/vsftpd/vsftpd.conf
COPY tools/ /usr/local/bin/
RUN chmod +x /usr/local/bin/*.sh

EXPOSE 21 21000-21010

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/ftp-entrypoint.sh"]