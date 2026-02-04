# User Documentation

**Services Provided**
- NGINX reverse proxy with TLS 1.2/1.3 on port 443.
- WordPress with PHP-FPM (served through NGINX).
- MariaDB database for WordPress.
- Redis cache for WordPress.
- FTP server for file access to the WordPress volume.
- Adminer for database administration.
- Static site served behind NGINX.
- cAdvisor for container metrics.

**Start and Stop**
- Start: `make up`
- Stop: `make down`
- Full cleanup: `make clean`

**Access the Website and Admin Panel**
- Website: `https://<DOMAIN_NAME>`
- WordPress admin: `https://<DOMAIN_NAME>/wp-admin`
- Adminer: `https://<DOMAIN_NAME>/adminer/`
- Static site: `https://<DOMAIN_NAME>/static/`
- cAdvisor: `https://<DOMAIN_NAME>/cadvisor/`

**FTP Access**
- Host: `<DOMAIN_NAME>` or VM IP
- Port: `21` (passive mode enabled)
- User: `FTP_USER` from `srcs/.env`
- Password: `FTP_PASSWORD` from `srcs/.env`
- Upload files to `wp-content/uploads/` to make them visible on the site.

**Locate and Manage Credentials**
- Environment variables: `srcs/.env`
- Secrets: `secrets/db_password.txt`, `secrets/db_root_password.txt`
- WordPress admin credentials: `WP_ADMIN_USER` and `WP_ADMIN_PASSWORD` in `srcs/.env`

**Check Services Are Running**
- `make ps`
- `docker compose --project-directory srcs -f srcs/docker-compose.yml ps`
- `docker compose --project-directory srcs -f srcs/docker-compose.yml logs -f <service>`
