FROM debian:bullseye

ARG PORTAINER_VERSION=2.18.1
ARG PORTAINER_ARCH=linux-amd64
ENV DOCKER_API_VERSION=1.44

RUN apt update -y \
    && apt upgrade -y \
    && apt install -y curl tar ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL "https://github.com/portainer/portainer/releases/download/${PORTAINER_VERSION}/portainer-${PORTAINER_VERSION}-${PORTAINER_ARCH}.tar.gz" -o /tmp/portainer.tar.gz \
    && tar -xvzf /tmp/portainer.tar.gz -C /tmp \
    && mv /tmp/portainer /usr/local/bin/ \
    && rm /tmp/portainer.tar.gz \
    && mkdir -p /data

EXPOSE 9001

ENTRYPOINT ["/usr/local/bin/portainer/portainer"]
CMD ["--bind", ":9001", "--data", "/data", "--host", "unix:///var/run/docker.sock"]
