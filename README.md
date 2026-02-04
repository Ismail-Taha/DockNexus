*This project has been created as part of the 42 curriculum by isallali.*

# Inception

**Description**
This project builds a small infrastructure using Docker Compose inside a VM. It includes an NGINX reverse proxy with TLS 1.2/1.3, WordPress with PHP-FPM, and MariaDB, plus named volumes for persistent data and a dedicated Docker network. Bonus services include Redis cache, FTP access to the WordPress volume, Adminer, a static site, and cAdvisor.

**Instructions**
1. Configure your domain to point to the VM IP (example: add `isallali.42.fr` in `/etc/hosts`).
2. Create `.env` at `srcs/.env` and secrets in `secrets/` (see `DEV_DOC.md`).
3. Start the stack with `make up`.
4. Access the site at `https://<DOMAIN_NAME>`.
5. Stop the stack with `make down`.

**Project Description**
This repository contains Dockerfiles, configuration files, and entrypoint scripts for each service, all built locally without pulling prebuilt images (except the base Alpine/Debian layers). Containers are connected via a dedicated network named `inception`. Data persistence is provided through named volumes mapped to `/home/<login>/data` on the host, following the subject requirements. The project sources included are the Dockerfiles, service configs, shell scripts, and diagrams under `diagrams/`.

**Comparison: Virtual Machines vs Docker**
Docker containers share the host kernel and start quickly, which is ideal for lightweight service isolation. Virtual machines virtualize entire operating systems and are heavier, but provide stronger isolation. This project uses Docker for efficiency and to focus on service orchestration.

**Comparison: Secrets vs Environment Variables**
Environment variables are easy to inject but can leak via process inspection or logs. Docker secrets are mounted as files and reduce exposure. This project uses secrets for database credentials and env vars for non-sensitive configuration.

**Comparison: Docker Network vs Host Network**
A Docker network provides isolated service-to-service communication without exposing internal ports on the host. Host networking removes isolation and is forbidden by the subject. This project uses a dedicated bridge network.

**Comparison: Docker Volumes vs Bind Mounts**
Bind mounts map arbitrary host paths directly into containers, which can be flexible but less portable. Named volumes are managed by Docker and are more predictable. This project uses named volumes mapped to `/home/<login>/data` as required.

**Resources**
- Docker Compose documentation
- NGINX TLS configuration docs
- WordPress and WP-CLI documentation
- MariaDB documentation
- Redis documentation
- vsftpd documentation
- Adminer documentation
- cAdvisor documentation

AI usage: AI assistance was used to draft documentation and refactor shell scripts, and all outputs were reviewed, adapted, and tested manually.

**Diagrams**
Architecture diagrams are stored in `diagrams/`. The subject PDF is at `diagrams/incep.pdf`.
