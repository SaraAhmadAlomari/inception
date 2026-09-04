#!/bin/bash
set -e

# Substitute the domain name coming from the .env file into nginx.conf
sed -i "s/__DOMAIN_NAME__/${DOMAIN_NAME}/g" /etc/nginx/nginx.conf

mkdir -p /etc/nginx/ssl

if [ ! -f /etc/nginx/ssl/server.crt ]; then
    openssl req -x509 -nodes -days 365 \
        -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/server.key \
        -out /etc/nginx/ssl/server.crt \
        -subj "/C=JO/ST=Amman/L=Amman/O=42/OU=Student/CN=${DOMAIN_NAME}"
fi

exec nginx -g "daemon off;"
