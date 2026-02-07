FROM debian:bookworm

RUN apt-get update \
    && apt-get install -y ca-certificates wget build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN wget -qO /usr/local/bin/cadvisor \
        "https://github.com/google/cadvisor/releases/download/v0.54.1/cadvisor-v0.54.1-linux-amd64" \
    && chmod +x /usr/local/bin/cadvisor

EXPOSE 8000

ENTRYPOINT ["/usr/local/bin/cadvisor", "--port=8080", "--url_base_prefix=/cadvisor"]
