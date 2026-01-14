FROM debian:bookworm-slim

RUN apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false \
    && apt-get install -y --no-install-recommends \
        mariadb-server \
        mariadb-client \
    && rm -rf /var/lib/apt/lists/*

COPY tools/ /usr/local/bin/

COPY conf/ /etc/mysql/mariadb.conf.d/

RUN chmod +x /usr/local/bin/*.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/mariadb-entrypoint.sh"]
