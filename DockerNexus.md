# DockerNexus

## 0) Goal of This Document
This file is designed for defense and interview preparation.
It has two layers:
1. Validate the current project against Inception requirements.
2. Teach Docker from zero to internals so you can explain not only what you built, but how it works under the hood.

Target reader:
- Someone with no Docker background.
- A reviewer asking deep technical questions (kernel, runtime, networking, storage, security, Compose internals).

---

## 1) References Used First
Primary references requested:
- `diagrams/incep.pdf`
- `evaluation.txt`

Project sources reviewed for implementation proof:
- `srcs/docker-compose.yml`
- `srcs/requirements/**/Dockerfile`
- `srcs/requirements/**/conf/*`
- `srcs/requirements/**/tools/*`
- `Makefile`
- `README.md`
- `USER_DOC.md`
- `DEV_DOC.md`
- `diagrams/*.mmd`

Status snapshot date:
- February 11, 2026

---

## 2) Requirement Validation Summary (Inception)

## 2.1 Repository Structure and Build Entry
- `srcs/` exists at root: PASS
- `Makefile` exists at root: PASS
- `srcs/docker-compose.yml` is used by Make targets: PASS

Evidence:
- `Makefile`
- `srcs/docker-compose.yml`

## 2.2 Compose Rule Compliance
- `network: host` absent: PASS
- `links:` absent: PASS
- Dedicated network configured: PASS
- Image names match service names: PASS
- `latest` tag not used: PASS

Evidence:
- `srcs/docker-compose.yml`

## 2.3 Dockerfile and Runtime Rule Compliance
- One Dockerfile per service: PASS
- Mandatory services each have dedicated container: PASS
- No forbidden infinite-loop hacks (`tail -f`, `sleep infinity`, `while true`): PASS
- Daemons run foreground as PID 1: PASS

Evidence:
- `srcs/requirements/**/Dockerfile`
- `srcs/requirements/**/tools/*.sh`

## 2.4 Mandatory Services
- NGINX with TLS 1.2/1.3: PASS
- WordPress with PHP-FPM only (no NGINX inside): PASS
- MariaDB only (no NGINX inside): PASS
- NGINX exposed as main web entry on `443`: PASS

Evidence:
- `srcs/requirements/nginx/conf/nginx.conf`
- `srcs/docker-compose.yml`
- `srcs/requirements/wordpress/Dockerfile`
- `srcs/requirements/mariadb/Dockerfile`

## 2.5 Volumes and Persistence
- WordPress data volume: PASS
- MariaDB data volume: PASS
- Host mapping matches `${HOME}/data/...` pattern required by subject intent: PASS

Evidence:
- `srcs/docker-compose.yml`
- `Makefile`

## 2.6 Secrets and Environment Variables
- Environment variables used: PASS
- Docker secrets used for DB passwords: PASS
- Passwords not hardcoded in Dockerfiles: PASS
- `.gitignore` excludes sensitive local files: PASS

Evidence:
- `.gitignore`
- `srcs/docker-compose.yml`
- `srcs/requirements/mariadb/tools/mariadb-entrypoint.sh`
- `srcs/requirements/wordpress/tools/setup.sh`

## 2.7 WordPress Functional Expectations
- Auto-install logic present: PASS
- Two users created: PASS
- Admin username restriction is currently satisfied by local env value: PASS
- Note: script does not enforce forbidden admin substrings automatically

Evidence:
- `srcs/requirements/wordpress/tools/setup.sh`
- `srcs/.env` (local)

## 2.8 Documentation Checklist
- `README.md` present and structured for evaluator expectations: PASS
- `USER_DOC.md` present: PASS
- `DEV_DOC.md` present: PASS

## 2.9 Bonus Services
- Redis cache: PASS
- FTP to WordPress volume: PASS
- Static non-PHP website: PASS
- Adminer: PASS
- Extra useful service (cAdvisor): PASS

Evidence:
- `srcs/requirements/bonus/*`
- `srcs/docker-compose.yml`

## 2.10 Important Notes for Defense
- Static validation is complete at source-code level.
- Live evaluation still requires runtime checks:
  - TLS handshake behavior
  - WordPress comment/page updates
  - MariaDB content inspection
  - Reboot persistence
  - Requested on-the-fly config change

---

## 3) Docker Fundamentals (Start From Zero)

## 3.1 What Docker Is
Docker is a platform to package and run applications in isolated environments called containers.
A container includes:
- App code
- Runtime dependencies
- System libraries
- Startup configuration

A container does not include a separate kernel.
It shares the host Linux kernel.

## 3.2 Why Docker Exists
Traditional deployment issues:
- "Works on my machine" mismatch
- Manual server configuration drift
- Hard reproducibility
- Slow setup for multi-service systems

Docker solves this by making environments reproducible and portable through images.

## 3.3 Container vs Virtual Machine
Virtual Machine:
- Has full guest OS and its own kernel
- Strong isolation but heavier resource overhead

Container:
- Shares host kernel
- Isolated process/filesystem/network view
- Faster startup, lighter footprint

Inception uses containers because it needs multiple isolated services with low overhead.

## 3.4 Image vs Container
Image:
- Read-only blueprint
- Built from Dockerfile layers

Container:
- Running instance of an image
- Adds a thin writable layer on top

Think:
- Image = class/template
- Container = object/instance

---

## 4) Docker Engine Architecture (Internal)

## 4.1 Main Components
When you run `docker` commands, multiple layers are involved:
1. Docker CLI (`docker`, `docker compose`)
2. Docker Engine daemon (`dockerd`)
3. `containerd` runtime manager
4. OCI low-level runtime (`runc` by default)
5. Linux kernel features (namespaces, cgroups, capabilities, mounts, networking)

## 4.2 Call Path Example (`docker run`)
1. CLI sends REST API request to `dockerd` over Unix socket.
2. `dockerd` resolves image, storage, network, and security config.
3. `dockerd` asks `containerd` to create container task.
4. `containerd` calls OCI runtime (`runc`) with OCI spec.
5. `runc` asks kernel to:
   - create namespaces
   - apply cgroup constraints
   - mount root filesystem
   - set process credentials/capabilities
6. Container process starts as PID 1 inside its PID namespace.

## 4.3 OCI Standards
OCI (Open Container Initiative) defines common formats for:
- Image specification
- Runtime specification

Why it matters:
- Tool interoperability
- Docker is not the only runtime ecosystem, but uses OCI-compatible flow.

## 4.4 What `containerd-shim` Does
A shim process helps keep containers alive independently of CLI sessions and handles stdio/reaping tasks between daemon and container runtime lifecycle.

---

## 5) How Linux Makes Containers Possible
Containers are not magic. They are a combination of Linux kernel primitives.

## 5.1 Namespaces (Isolation)
Namespaces give a process a private view of system resources.

Key namespace types:
- `pid`: isolated process ID tree
- `net`: isolated network stack (interfaces, routes, firewall namespace scope)
- `mnt`: isolated mount points/filesystem view
- `uts`: isolated hostname/domain name
- `ipc`: isolated shared memory/semaphores/message queues
- `user`: isolated UID/GID mapping
- `cgroup`: isolated cgroup hierarchy view

Interview explanation:
- "A container is mostly a process running with multiple namespaces plus resource policies."

## 5.2 cgroups (Resource Control)
cgroups control and account resource usage for process groups.

Important controllers:
- CPU shares/quotas
- memory limits and OOM behavior
- pids count limit
- blkio/io throttling

What this gives you:
- One container cannot starve the entire host by default policy.
- Resource governance for multi-service deployment.

## 5.3 Capabilities (Privilege Splitting)
Linux root privileges are split into capabilities.
Containers typically drop many capabilities by default.
This reduces blast radius compared to fully privileged root.

## 5.4 seccomp / LSM
- seccomp: syscall filtering
- AppArmor/SELinux: mandatory access control

Together they harden runtime behavior beyond basic namespace isolation.

---

## 6) Container Filesystem Internals

## 6.1 Layered Image Filesystem
Docker images are layered.
Each Dockerfile instruction typically creates a layer.

Benefits:
- Reuse shared base layers
- Faster pulls and builds via cache

## 6.2 Copy-on-Write
Containers start with read-only image layers and add one writable layer.
When a file is changed:
- File is copied to writable layer
- Modification applies there

This mechanism is copy-on-write (CoW).

## 6.3 `overlay2` (Common Storage Driver)
On Linux, Docker often uses `overlay2`.
Conceptual directories:
- lowerdir: image layers
- upperdir: container writable layer
- merged: unified mount seen by process
- workdir: internal overlay work area

## 6.4 Why Volumes Exist
Container writable layer is ephemeral.
Deleting container loses that layer.
Volumes persist data independent of container lifecycle.

In this project:
- WordPress files persist in `wordpress_data`
- MariaDB files persist in `mariadb_data`

---

## 7) Docker Networking Internals

## 7.1 Bridge Networking
Default Compose networking uses Linux bridge.
Each container gets:
- virtual ethernet pair (veth)
- private IP on bridge subnet

## 7.2 NAT and Port Publishing
When you publish `443:443`, Docker configures host networking rules (iptables/nftables stack depending host setup) so external traffic reaches container port.

## 7.3 Internal DNS
Compose injects service discovery via embedded DNS.
Service names become resolvable hostnames on shared network.

Example in this stack:
- `wordpress` reaches `mariadb`
- `nginx` reaches `wordpress`, `adminer`, `static`, `cadvisor`

## 7.4 Why `network: host` Is Forbidden Here
Host mode removes network isolation and bypasses Compose network design expected by subject.

---

## 8) Docker Build Internals

## 8.1 Dockerfile Build Stages
Build steps:
1. Parse Dockerfile
2. Resolve base image
3. Execute instructions in order
4. Snapshot layer after each relevant step
5. Tag final image

## 8.2 Build Cache
If instruction inputs do not change, Docker reuses cached layers.
This speeds rebuilds.

Cache invalidation rule of thumb:
- Once one layer changes, downstream layers usually rebuild.

## 8.3 Why Order Matters in Dockerfile
Place rarely changing steps first (package install), frequently changing app files later.
This maximizes cache reuse.

## 8.4 Build Context
Compose sends build context directory to Docker daemon.
Only files in that context can be copied in Dockerfile.

---

## 9) Docker Compose Deep Explanation

## 9.1 What Compose Is
Compose is an orchestration tool for defining and running multi-container applications.
You declare desired state in YAML, Compose converges runtime to that state.

## 9.2 Compose Concept Model
Main objects:
- services
- networks
- volumes
- secrets
- configs (not used here)

## 9.3 What Happens Internally on `docker compose up`
1. Parse YAML and interpolate env vars.
2. Compute project name and resource names.
3. Build images for services with `build:`.
4. Create required network(s) if missing.
5. Create required volume(s) if missing.
6. Create containers with merged config.
7. Start containers respecting dependency graph.
8. Attach logs (foreground mode) or detach (`-d`).

## 9.4 `depends_on` Reality
`depends_on` ensures start order, not application readiness.
Readiness must be handled by:
- healthchecks
- wait-for-it logic
- retry loops in app startup scripts

This project handles DB readiness in WordPress script with a loop checking MariaDB availability.

## 9.5 Compose Environment Resolution
Compose can load env values from:
- `.env` file
- shell environment
- `env_file`
- inline `environment`

Runtime container env is the merge output with precedence rules.

## 9.6 Compose Secrets in This Project
Secrets are mounted as files under `/run/secrets/<name>` inside relevant containers.
This is used for DB password injection.

## 9.7 Compose Idempotency
Repeated `docker compose up -d`:
- does not always recreate everything
- recreates only changed resources when needed

This supports stable iterative development.

---

## 10) Security Concepts You Should Explain in Defense

## 10.1 Why Containers Are Not Full Sandboxes
Isolation is strong for app deployment, but containers share kernel.
Kernel vulnerabilities can affect all containers.

## 10.2 Hardening Basics
- Least privilege
- Minimize package surface
- Avoid running as root where possible
- Use secrets for sensitive data
- Keep base image and packages updated
- Restrict published ports

## 10.3 Password Handling
Avoid hardcoding in Dockerfiles or committed config.
Use:
- secrets for credentials
- env vars for non-sensitive settings

## 10.4 TLS Termination Design
This project centralizes HTTPS entry in NGINX.
Benefits:
- single security choke point
- consistent certificates and cipher policy
- no direct external exposure of internal services

---

## 11) Mapping Internals to This Project

## 11.1 Services and Their Roles
- `nginx`: ingress, TLS termination, reverse proxy
- `wordpress`: PHP-FPM + WP-CLI bootstrap
- `mariadb`: relational DB service
- `redis` (bonus): object caching backend
- `ftp` (bonus): file transfer to WordPress volume
- `adminer` (bonus): DB web UI
- `static` (bonus): plain HTML site
- `cadvisor` (bonus extra): container metrics

## 11.2 Runtime Data Paths
- `/var/www/html` in WordPress and NGINX -> `wordpress_data`
- `/var/lib/mysql` in MariaDB -> `mariadb_data`

## 11.3 Network Flow
- External client can reach NGINX on 443 only.
- NGINX proxies internally by service DNS names.
- Internal services are not directly exposed (except FTP bonus ports).

## 11.4 NGINX Domain Templating
Current implementation renders `server_name` from `DOMAIN_NAME` at container start.
Mechanism:
- Template file copied as `default.conf.template`
- Entrypoint replaces `__DOMAIN_NAME__` placeholder
- Final config written to `default.conf`

This supports portability and defense reconfiguration.

---

## 12) End-to-End Startup Flow for This Stack

1. `make up` creates host data dirs and runs Compose up with build.
2. Docker builds each image from local Dockerfiles.
3. Compose creates network and volumes.
4. MariaDB starts and initializes DB/user on first run.
5. WordPress waits for MariaDB, installs core/site/users if needed.
6. NGINX generates self-signed cert if absent and starts HTTPS listener.
7. Bonus services run and are available through NGINX paths.

---

## 13) Service-by-Service Technical Notes

## 13.1 NGINX
Path: `srcs/requirements/nginx`
- Base: Debian slim
- Startup script generates cert (if missing)
- TLS policy: v1.2 and v1.3 only
- Reverse proxy routes for WordPress, Adminer, Static, cAdvisor

## 13.2 WordPress
Path: `srcs/requirements/wordpress`
- Installs PHP-FPM and needed extensions
- Uses WP-CLI for bootstrap automation
- Waits for DB readiness
- Creates admin and second user
- Optional Redis plugin setup

## 13.3 MariaDB
Path: `srcs/requirements/mariadb`
- Initializes datadir first run
- Sets root password from secret
- Creates app DB and user
- Runs foreground daemon

## 13.4 Redis
Path: `srcs/requirements/bonus/redis`
- In-memory data store
- Used for object caching by WordPress plugin

## 13.5 FTP
Path: `srcs/requirements/bonus/ftp`
- `vsftpd` with passive mode range
- User provisioned from environment
- WordPress volume shared for uploads

## 13.6 Adminer
Path: `srcs/requirements/bonus/adminer`
- Lightweight DB admin web tool
- Proxied under `/adminer/`

## 13.7 Static
Path: `srcs/requirements/bonus/static`
- Plain static content over NGINX
- No PHP

## 13.8 cAdvisor
Path: `srcs/requirements/bonus/cadvisor`
- Exposes container resource metrics
- Useful as justified "service of your choice"

---

## 14) Must-Know Interview Topics and Ready Answers

## 14.1 "What is a container, really?"
A container is a regular Linux process isolated by namespaces and limited by cgroups, running in a controlled root filesystem.

## 14.2 "Where is the boundary between Docker and Linux kernel?"
Docker orchestrates. Kernel enforces.
Docker configures namespaces/cgroups/mounts through runtime tools; kernel provides the primitives.

## 14.3 "Why is PID 1 special in containers?"
PID 1 handles signals and child reaping.
If entrypoint is wrong, stop/restart behavior can break and zombie processes can accumulate.

## 14.4 "Why not use `tail -f` to keep container alive?"
Because it hides process management bugs, violates best practices, and breaks proper lifecycle semantics.
Run the real service in foreground instead.

## 14.5 "Why use Compose if I can run `docker run` many times?"
Compose gives declarative, repeatable multi-service orchestration with networking, volumes, and dependencies in one file.

## 14.6 "Difference between bind mount and volume?"
Bind mount maps exact host path.
Named volume is managed by Docker.
This project uses named volumes backed by host paths to satisfy subject directory constraints.

## 14.7 "How do containers resolve each other by name?"
Compose network provides embedded DNS.
Service names resolve to container IPs on that network.

## 14.8 "Is `depends_on` enough for readiness?"
No. It controls start order only. App readiness needs healthchecks or retry logic.

## 14.9 "How does TLS work here?"
Client negotiates TLS with NGINX on 443.
NGINX decrypts and forwards internal HTTP/FastCGI traffic to backend services.

## 14.10 "Why no HTTP port 80?"
Subject requires secure single entry via TLS on port 443.

## 14.11 "How do secrets improve over plain env vars?"
Secrets reduce accidental exposure in process env dumps and config output, and support file-based secure reads.

## 14.12 "What survives container rebuild?"
Only data on volumes (or external storage), not writable container layer.

## 14.13 "What is copy-on-write impact?"
Good for image sharing efficiency; less ideal for high-write persistent DB paths, so DB uses volume.

## 14.14 "What does restart policy do?"
`restart: always` asks Docker to restart container after failure and daemon restart.

## 14.15 "Why NGINX and PHP-FPM split?"
Separation of concerns:
- NGINX handles HTTP/TLS/static/reverse proxy
- PHP-FPM handles PHP execution

---

## 15) Troubleshooting and Debug Playbook

## 15.1 General
- `make ps`
- `make logs`
- `docker compose --project-directory srcs -f srcs/docker-compose.yml logs -f <service>`

## 15.2 Networking
- `docker network ls`
- `docker network inspect inception`
- from container: `getent hosts mariadb` (if tooling available)

## 15.3 Volumes
- `docker volume ls`
- `docker volume inspect wordpress`
- `docker volume inspect mariadb`

## 15.4 TLS
- `curl -kI https://<DOMAIN_NAME>`
- verify http is not serving target app

## 15.5 WordPress
- `docker compose --project-directory srcs -f srcs/docker-compose.yml exec -T wordpress wp core is-installed --allow-root --path=/var/www/html`
- `docker compose --project-directory srcs -f srcs/docker-compose.yml exec -T wordpress wp user list --allow-root --path=/var/www/html`

## 15.6 MariaDB
- `docker compose --project-directory srcs -f srcs/docker-compose.yml exec -T mariadb sh -c 'mariadb -u"$MYSQL_USER" -p"$(cat /run/secrets/db_password)" "$MYSQL_DATABASE" -e "SHOW TABLES;"'`

---

## 16) Defense Execution Script (What to Demonstrate Live)

1. Clean start and build with Makefile.
2. Show only 443 published for web ingress.
3. Open HTTPS site and prove WordPress already installed.
4. Login admin dashboard and modify content.
5. Add comment as non-admin user.
6. Show DB contains WordPress tables.
7. Show volume mount points under `/home/<login>/data/...`.
8. Restart stack or reboot VM and prove persistence.
9. Perform quick config modification requested by evaluator and rebuild successfully.
10. Explain one internal concept deeply (namespaces/cgroups/overlay2/Compose graph) without reading notes.

---

## 17) Quick Glossary
- Docker Engine: daemon runtime platform (`dockerd`)
- Image: immutable layered template
- Container: running isolated process instance
- Namespace: resource visibility isolation
- cgroup: resource quota/accounting control
- OverlayFS: layered filesystem implementation
- Volume: persistent data storage outside container writable layer
- Compose: declarative multi-container orchestrator
- OCI: open standards for image/runtime specs
- PID 1: init-like main process in container namespace
- FastCGI: protocol used by NGINX to communicate with PHP-FPM

---

## 18) Final Assessment
This project is a valid Inception implementation at source level and now has documentation suitable for both:
- beginner onboarding
- deep technical interview/evaluation defense

If you study this file section-by-section and rehearse the defense script, you will be able to explain not only "how to run" the stack, but also "how containerization works internally".
