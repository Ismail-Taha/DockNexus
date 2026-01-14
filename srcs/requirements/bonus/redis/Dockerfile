FROM alpine:3.19

RUN apk add --no-cache redis \
 && mkdir -p /data \
 && chown redis:redis /data

# VOLUME ["/data"]

EXPOSE 6379

ENTRYPOINT ["redis-server", "--protected-mode", "no", "--dir", "/data", "--appendonly", "yes"]
