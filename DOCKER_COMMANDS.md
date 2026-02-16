# Docker Command Reference

**Compose Basics**
- Start: `docker compose --project-directory srcs -f srcs/docker-compose.yml up -d --build`
- Stop: `docker compose --project-directory srcs -f srcs/docker-compose.yml down`
- Rebuild images: `docker compose --project-directory srcs -f srcs/docker-compose.yml build`
- Remove volumes: `docker compose --project-directory srcs -f srcs/docker-compose.yml down --volumes --remove-orphans`

**Service Status and Logs**
- List services: `docker compose --project-directory srcs -f srcs/docker-compose.yml ps`
- Logs: `docker compose --project-directory srcs -f srcs/docker-compose.yml logs -f <service>`

**Enter Containers**
- NGINX: `docker compose --project-directory srcs -f srcs/docker-compose.yml exec nginx sh`
- WordPress: `docker compose --project-directory srcs -f srcs/docker-compose.yml exec wordpress bash`
- MariaDB: `docker compose --project-directory srcs -f srcs/docker-compose.yml exec mariadb bash`
- Redis: `docker compose --project-directory srcs -f srcs/docker-compose.yml exec redis sh`
- FTP: `docker compose --project-directory srcs -f srcs/docker-compose.yml exec ftp sh`
- Adminer: `docker compose --project-directory srcs -f srcs/docker-compose.yml exec adminer sh`
- Static: `docker compose --project-directory srcs -f srcs/docker-compose.yml exec static sh`
- cAdvisor: `docker compose --project-directory srcs -f srcs/docker-compose.yml exec cadvisor sh`

**MariaDB Access**
- Root login from the host:
  - `docker compose --project-directory srcs -f srcs/docker-compose.yml exec -T mariadb sh -c 'mariadb -uroot -p"$(cat /run/secrets/db_root_password)"'`
- List users:
  - `docker compose --project-directory srcs -f srcs/docker-compose.yml exec -T mariadb sh -c 'mariadb -uroot -p"$(cat /run/secrets/db_root_password)" -e "SELECT User, Host FROM mysql.user;"'`
- WordPress DB login:
  - `docker compose --project-directory srcs -f srcs/docker-compose.yml exec -T mariadb sh -c 'mariadb -u"$MYSQL_USER" -p"$(cat /run/secrets/db_password)" "$MYSQL_DATABASE"'`

**WordPress CLI**
- List WP users:
  - `docker compose --project-directory srcs -f srcs/docker-compose.yml exec -T wordpress wp user list --allow-root --path=/var/www/html`

**Volumes and Network**
- List volumes: `docker volume ls`
- Inspect volumes: `docker volume inspect mariadb` and `docker volume inspect wordpress`
- List networks: `docker network ls`
- Inspect network: `docker network inspect inception`

**Quick Health Checks**
- Verify TLS endpoint: `curl -k https://<DOMAIN_NAME>`
- Verify Adminer: `curl -k https://<DOMAIN_NAME>/adminer/`
- Verify static site: `curl -k https://<DOMAIN_NAME>/static/`
- Verify cAdvisor: `curl -k https://<DOMAIN_NAME>/cadvisor/`
