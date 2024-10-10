#!/bin/bash

# Ensure default Nginx config is removed (as root)
if [ -f /etc/nginx/conf.d/default.conf ]; then
    rm /etc/nginx/conf.d/default.conf
fi

# Switch to non-root user for application
exec gosu laravel "$@"


set -e

# Start MariaDB
service mariadb start

# Wait for MariaDB to be ready
max_tries=30
counter=1
while ! mysqladmin ping -h"localhost" --silent; do
    sleep 1
    counter=$((counter + 1))
    if [ $counter -gt $max_tries ]; then
        >&2 echo "MariaDB failed to start after $max_tries seconds"
        exit 1
    fi
done

# Create storage directory structure if it doesn't exist
mkdir -p /var/www/html/storage/logs
mkdir -p /var/www/html/storage/framework/{sessions,views,cache}

# Set proper permissions again (in case of mounted volumes)
chown -R www-data:www-data /var/www/html/storage
chmod -R 775 /var/www/html/storage

# Start Nginx
service nginx start

php artisan migrate

# Execute CMD
exec "$@"