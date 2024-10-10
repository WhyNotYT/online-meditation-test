# Base image with PHP-FPM and Nginx
FROM jkaninda/nginx-php-fpm:8.3

# Set working directory
WORKDIR /var/www/html

# Install MariaDB and supervisor
RUN apt-get update && \
    apt-get install -y mariadb-server supervisor && \
    rm -rf /var/lib/apt/lists/*

# Create necessary directories with correct permissions
RUN mkdir -p /var/run/php && \
    mkdir -p /var/run/nginx && \
    mkdir -p /var/lib/nginx && \
    mkdir -p /var/log/nginx && \
    mkdir -p /var/log/supervisor && \
    mkdir -p /var/run/mysqld && \
    mkdir -p /etc/supervisor/conf.d && \
    mkdir -p /var/lib/mysql && \
    # Assign correct permissions for all directories
    chmod -R 777 /var/run/php && \
    chmod -R 777 /var/run/nginx && \
    chmod -R 777 /var/lib/nginx && \
    chmod -R 777 /var/log/nginx && \
    chmod -R 777 /var/log/supervisor && \
    chmod -R 777 /var/run/mysqld && \
    chmod -R 777 /etc/supervisor/conf.d && \
    chmod -R 777 /var/lib/mysql

# Ensure PHP-FPM directories exist and have the right permissions
RUN chown www-data:www-data /run/php

# Copy project files
COPY . .

# Install PHP dependencies using Composer
RUN composer install --no-dev --optimize-autoloader

# Fix permissions for storage and cache directories
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache && \
    chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Initialize MariaDB data directory
RUN mysql_install_db --user=mysql --datadir=/var/lib/mysql

# Remove default Nginx config during build
RUN rm /etc/nginx/conf.d/default.conf

# Copy configuration files
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY php-fpm.conf /usr/local/etc/php-fpm.conf

# Define the document root for Nginx
ENV DOCUMENT_ROOT=/var/www/html/public

# Expose port 80 (default for HTTP)
EXPOSE 80

# Run Laravel key generation and other necessary commands
RUN php artisan key:generate

# Switch to non-root user (www-data) for runtime
USER root

# Use supervisor as the entry point
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
