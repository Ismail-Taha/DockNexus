FROM debian:bullseye-slim

ARG CADVISOR_VERSION=0.54.1

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates wget \
    && rm -rf /var/lib/apt/lists/*

RUN wget -qO /usr/local/bin/cadvisor \
        "https://github.com/google/cadvisor/releases/download/v${CADVISOR_VERSION}/cadvisor-v${CADVISOR_VERSION}-linux-amd64" \
    && chmod +x /usr/local/bin/cadvisor

COPY --chmod=755 ./tools/entrypoint.sh /entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
