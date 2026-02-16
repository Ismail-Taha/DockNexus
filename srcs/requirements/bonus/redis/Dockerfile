FROM debian:bookworm

RUN apt-get update && apt-get install -y redis \
 && mkdir -p /data \
 && chown redis:redis /data

# VOLUME ["/data"]

EXPOSE 6379

ENTRYPOINT ["redis-server", "--protected-mode", "no", "--dir", "/data", "--appendonly", "yes"]
