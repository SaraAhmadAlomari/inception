# User Documentation

This document is for anyone who wants to **use** the Inception stack (visit the site, log in, and check that everything is running) without needing to know how it was built.

## 1. What services does the stack provide?

| Service     | Role                                                               |
| ----------- | ------------------------------------------------------------------ |
| `nginx`     | Public HTTPS entry point on port 443 using TLSv1.2/1.3.            |
| `wordpress` | The website (WordPress + PHP-FPM), reachable only through `nginx`. |
| `mariadb`   | The database used by WordPress, reachable only from `wordpress`.   |

## 2. Starting and stopping the activity

From the project root, where the `Makefile` is located:

```bash
make          # build and start everything
make down     # stop and remove the containers
make re       # full rebuild from scratch
```

To check that everything is running:

```bash
make ps
```

All three containers should show a state of `Up`.

## 3. Accessing the website and administration panel

* **Website:** `https://saalomar.42.fr`
* **Admin panel:** `https://saalomar.42.fr/wp-admin`

The TLS certificate is self-signed and generated locally by the `nginx` container. Your browser may show a security warning the first time. This is expected.

## 4. Credentials

WordPress accounts are created automatically during the first setup.

| Account       | Username                         | Password                  |
| ------------- | -------------------------------- | ------------------------- |
| Administrator | `WP_ADMIN_USER` from `srcs/.env` | `secrets/credentials.txt` |
| Regular user  | `WP_USER` from `srcs/.env`       | `secrets/credentials.txt` |

The `credentials.txt` file contains:

```text
wp_admin_password=...
wp_user_password=...
```

The database credentials are stored separately:

| Account                    | Password                       |
| -------------------------- | ------------------------------ |
| DB app user (`MYSQL_USER`) | `secrets/db_password.txt`      |
| DB root                    | `secrets/db_root_password.txt` |

The `secrets/` folder is git-ignored on purpose. Never commit real passwords.

## 5. Checking that services are running correctly

```bash
# Container status
make ps

# Live logs of all services
make logs

# Logs of a specific service
docker compose -f srcs/docker-compose.yml logs -f nginx
docker compose -f srcs/docker-compose.yml logs -f wordpress
docker compose -f srcs/docker-compose.yml logs -f mariadb
```

A quick manual check:

```bash
curl -kI https://saalomar.42.fr
```

The response should show a successful HTTP status such as `200`.

If a container keeps restarting, check its logs first. All services use `restart: always`, so Docker will automatically restart a stopped container.

