FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends mariadb-server && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/lib/mysql

RUN mkdir -p /run/mysqld /var/lib/mysql && \
    chown -R mysql:mysql /run/mysqld /var/lib/mysql

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

RUN chown root:root /etc/mysql/mariadb.conf.d/50-server.cnf && \
    chmod 644 /etc/mysql/mariadb.conf.d/50-server.cnf

COPY tools/init.sh /usr/local/bin/init.sh

RUN chmod +x /usr/local/bin/init.sh

EXPOSE 3306

HEALTHCHECK --interval=5s --timeout=3s --retries=10 \
    CMD mariadb-admin ping \
        -h 127.0.0.1 \
        -uroot \
        -p"$(cat /run/secrets/db_root_password)" \
        --silent || exit 1

ENTRYPOINT ["/usr/local/bin/init.sh"]
