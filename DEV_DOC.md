# Developer Documentation

This document explains how to set up, build, and work on the Inception stack.

## 1. Setting up the environment from scratch

### Prerequisites

* A Linux Virtual Machine.
* `docker` and the `docker compose` plugin.
* `make`.

### Configuration files

```text
inception/
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── .gitignore
├── secrets/
│   ├── db_password.txt
│   ├── db_root_password.txt
│   └── credentials.txt
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── nginx/
        ├── wordpress/
        └── mariadb/
```

Before the first run:

* Configure `srcs/.env` with the domain, database settings, and WordPress settings.
* Add the required passwords to the files under `secrets/`.
* `credentials.txt` contains the WordPress administrator and regular-user passwords.
* Keep `secrets/` and `srcs/.env` private. They are excluded from Git.

The domain should resolve to the VM's IP address. For example, add the following to `/etc/hosts` on the machine used to access the website:

```text
<VM_IP>   saalomar.42.fr
```

## 2. Building and launching

From the project root:

```bash
make
```

This creates the required host data directories and builds and starts all services using Docker Compose.

Other useful commands:

```bash
make build    # build the images
make up       # start the containers
```

The Docker Compose file is:

```bash
srcs/docker-compose.yml
```

Each service has its own custom Dockerfile under:

```text
srcs/requirements/
├── nginx/
├── wordpress/
└── mariadb/
```

## 3. Managing containers and volumes

```bash
make ps        # show container status
make restart   # restart containers
make down      # stop and remove containers
make clean     # remove containers, images, and volumes
make fclean    # clean and remove host data directories
make re        # fclean + make
```

Direct Docker Compose commands can also be used:

```bash
docker compose -f srcs/docker-compose.yml exec wordpress bash
docker compose -f srcs/docker-compose.yml exec mariadb mysql -u root -p
docker volume ls
docker network ls
```

## 4. Data storage and persistence

The stack uses two named Docker volumes:

* `wordpress_data` → `/var/www/html` in the `nginx` and `wordpress` containers.
* `db_data` → `/var/lib/mysql` in the `mariadb` container.

The volumes are backed by host directories:

```text
/home/saalomar/data/wordpress
/home/saalomar/data/mariadb
```

The directories are configured in `srcs/docker-compose.yml` using the Docker `local` volume driver with bind options.

Therefore, the application and database data are stored outside the containers and persist when containers are stopped or removed with:

```bash
make down
```

`make clean` removes the Docker volumes, while `make fclean` also removes the host data directories.

## 5. First-boot behavior

### MariaDB

On the first run, `mariadb/tools/init.sh`:

* Initializes the database directory.
* Creates the database.
* Creates the WordPress database user.
* Sets the root password.

On later starts, the existing database is reused.

### WordPress

On the first run, `wordpress/tools/setup.sh`:

* Waits for MariaDB.
* Downloads WordPress.
* Creates `wp-config.php`.
* Installs WordPress.
* Creates the administrator and regular user.

On later starts, the existing WordPress installation is reused.

This allows the stack to be restarted without recreating the existing database or WordPress installation.

