*This activity has been created as part of the 42 curriculum by saalomar.*

# Inception

## Description

**Inception** is a system-administration project whose goal is to build, from scratch, a small
production-like web infrastructure using **Docker** and **Docker Compose**, entirely inside a
personal Virtual Machine.

The stack is made of single-service containers connected through a
dedicated Docker network:

- **NGINX** — HTTPS reverse proxy using TLS1.2/1.3) reverse proxy
  (port 443).
- **WordPress + php-fpm** — the actual website
- **MariaDB** — the database used by WordPress

The WordPress database and the WordPress site files is stored in two Docker
**named volumes**, bind-mounted to `/home/saalomar/data` on the host machine.

## Instructions

### Requirements
- A Linux Virtual Machine with `docker` and the `docker compose` plugin installed.
- make
    - make        → build + start
    - make down   → stop/remove containers
    - make clean  → remove containers/images/volumes
    - make fclean → clean + remove persistent data
### Setup
1. From the repository root, run:
   ```bash
   make
   ```
   This creates the host data directories, builds the three images, and starts the stack.
2. Visit `https://saalomar.42.fr` in your browser


## Resources

- [Docker documentation](https://docs.docker.com/)
- [Docker Compose file reference](https://docs.docker.com/compose/compose-file/)
- [WordPress WP-CLI documentation](https://wp-cli.org/)
- [MariaDB documentation](https://mariadb.com/kb/en/documentation/)
- [NGINX documentation](https://nginx.org/en/docs/)

**Use of AI**:
- Explain NGINX, PHP-FPM and MariaDB concept.
- Help troubleshoot errors encountered during development.

## Project description

### Use of Docker
Docker is used to move the different services of the application and run them in isolated environments. Each service has its own container, image, configuration, and runtime process.

- This project is contains three main containers:
    - NGINX : Only public entry point from 443 port (acts as web server).
    - WordPress / PHP-FPM : runs the WordPress application and processes PHP requests on port 9000.
    - MariaDB : provides the database used by WordPress and listens on port 3306 internally.

#### Sources Included in the Activity

- **NGINX**
Dockerfile
NGINX configuration
Startup script responsible for domain configuration and TLS certificate generation.

- **WordPress**
Dockerfile
PHP-FPM configuration
Startup script responsible for downloading and configuring WordPress, creating users, and setting file permissions.

- **MariaDB**
Dockerfile
MariaDB configuration
Initialization script responsible for initializing the database and creating the required database users.

- **Docker Compose**
Defines the three services.
Configures the Docker network, named volumes, secrets, ports, and service dependencies.

- **Makefile**
Provides commands to build, start, stop, clean, and manage the project.

- **Environment and Secret files**
Environment variables contain general configuration such as database names, usernames, domain name, and WordPress settings.
Docker Secrets are used for sensitive passwords.

- **data directories**
WordPress data
MariaDB data

## Main Design Choices

- **One container per service**
  - NGINX, WordPress/PHP-FPM, and MariaDB each run in a separate container.
  - This keeps each service isolated and follows the project's requirement to run each service in its own container.

- **Docker Compose**
  - Used to define, build, configure, and run all services together.
  - Handles networks, volumes, secrets, dependencies, and service configuration.

- **NGINX as the only public entry point**
  - Only NGINX exposes port `443` to the host.
  - It handles HTTPS/TLS and forwards PHP requests to WordPress/PHP-FPM.

- **PHP-FPM for WordPress**
  - WordPress runs through PHP-FPM on port `9000`.
  - NGINX communicates with PHP-FPM using FastCGI.

- **MariaDB as a separate database service**
  - MariaDB runs in its own container.
  - WordPress connects to it through the Docker network using the service name `mariadb`.

- **Dedicated Docker network**
  - All three services are connected to the `inception` bridge network.
  - Services communicate internally using Docker's service-name DNS.

- **Named volumes for persistent data**
  - WordPress files and MariaDB data are stored in named Docker volumes.
  - The volumes are backed by directories under `/home/saalomar/data`.

- **Docker Secrets for passwords**
  - Database and WordPress passwords are stored as Docker secrets instead of being directly placed in the Compose file.
  - Secrets are available inside the containers through `/run/secrets/`.

- **Initialization scripts**
  - Each service has a startup script responsible for runtime configuration and initialization.
  - MariaDB initializes the database, WordPress installs/configures WordPress, and NGINX generates the TLS certificate and configures the domain.

- **Foreground main processes**
  - NGINX, PHP-FPM, and MariaDB run as the main foreground process of their containers.
  - This allows Docker to correctly monitor the container lifecycle.

- **Minimal base images**
  - Debian `bookworm-slim` is used as the base image.
  - Only the packages required by each service are installed to keep the images lightweight.
  

### Key Comparisons

| Topic | Option 1 | Option 2 | Main Difference in This Project |
| :--- | :--- | :--- | :--- |
| **Virtual Machines vs Docker** | **Virtual Machine**: runs a complete operating system. | **Docker**: runs isolated containers sharing the host kernel. | Docker is lighter and faster. In this project, NGINX, WordPress, and MariaDB run in separate containers instead of separate VMs. |
| **Secrets vs Environment Variables** | **Environment Variables**: used for general configuration such as database name, username, and domain. | **Docker Secrets**: used for sensitive data such as passwords. | In this project, `.env` stores general configuration, while passwords are provided through `/run/secrets/`. |
| **Docker Network vs Host Network** | **Docker Network**: containers communicate through an isolated Docker network. | **Host Network**: containers use the host's network directly. | This project uses a bridge network called `inception`. NGINX connects to `wordpress:9000` and WordPress connects to `mariadb:3306` internally. |
| **Docker Volumes vs Bind Mounts** | **Docker Volume**: Docker manages the volume. | **Bind Mount**: directly maps a specific host directory. | This project uses **named volumes** for WordPress and MariaDB, backed by host directories under `/home/saalomar/data/`. |
