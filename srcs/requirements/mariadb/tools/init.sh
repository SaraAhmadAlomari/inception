#!/bin/bash
set -e

DB_PASSWORD=$(cat /run/secrets/db_password)
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql

if [ ! -d "/var/lib/mysql/mysql" ]; then

    echo "==> Initializing MariaDB data directory..."

    mariadb-install-db \
        --user=mysql \
        --datadir=/var/lib/mysql \
        --skip-test-db \
        --auth-root-authentication-method=normal

    echo "==> Creating initialization SQL..."

    cat > /var/lib/mysql/init.sql <<EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';

GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

ALTER USER 'root'@'localhost'
    IDENTIFIED VIA mysql_native_password
    USING PASSWORD('${DB_ROOT_PASSWORD}');

FLUSH PRIVILEGES;
EOF

    chown mysql:mysql /var/lib/mysql/init.sql
    chmod 600 /var/lib/mysql/init.sql

    echo "==> Starting MariaDB..."

    exec mariadbd \
        --user=mysql \
        --datadir=/var/lib/mysql \
        --init-file=/var/lib/mysql/init.sql \
        --console

else

    echo "==> MariaDB data directory already exists."

    echo "==> Starting MariaDB..."

    exec mariadbd \
        --user=mysql \
        --datadir=/var/lib/mysql \
        --console

fi
