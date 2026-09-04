FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        php8.2 \
        php8.2-fpm \
        php8.2-mysql \
        php8.2-curl \
        php8.2-gd \
        php8.2-xml \
        php8.2-mbstring \
        php8.2-zip \
        curl \
        ca-certificates \
        default-mysql-client \
        less \
    && rm -rf /var/lib/apt/lists/*

# wp-cli, used to actually install and configure WordPress (users, DB, etc.)
RUN curl -o /usr/local/bin/wp -sSL \
        https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x /usr/local/bin/wp

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY tools/setup.sh /usr/local/bin/setup.sh

RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 9000

HEALTHCHECK --interval=5s --timeout=3s --retries=10 \
    CMD bash -c 'exec 3<>/dev/tcp/127.0.0.1/9000' || exit 1

ENTRYPOINT ["/usr/local/bin/setup.sh"]
