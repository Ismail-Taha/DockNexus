# Developer Documentation

**Prerequisites**
- A Linux VM with Docker and Docker Compose installed.
- GNU Make installed.
- A local domain pointing to the VM IP, for example `<login>.42.fr` in `/etc/hosts`.

**Environment Setup**
1. Create `srcs/.env` with required values such as `DOMAIN_NAME`, `MYSQL_USER`, `WP_ADMIN_USER`, and others.
2. Create secrets:
   - `secrets/db_password.txt`
   - `secrets/db_root_password.txt`
3. Ensure data directories exist at `/home/<login>/data` (handled by `make up`).

**Build and Launch**
- Build and start: `make up`
- Rebuild without cache: `make build`
- Stop without deleting volumes: `make down`
- Remove containers and volumes: `make clean`
- Full reset including data: `make reset`

**Manage Containers and Volumes**
- List services: `make ps`
- Tail logs: `make logs`
- Inspect volumes:
  - `docker volume ls`
  - `docker volume inspect mariadb`
  - `docker volume inspect wordpress`

**Data Persistence**
- MariaDB data persists at `/home/<login>/data/mariadb`.
- WordPress files persist at `/home/<login>/data/wordpress`.

**Notes**
- Database passwords are read from Docker secrets inside the containers.
- If database credentials change, remove the MariaDB volume and reinitialize with `make reset`.
