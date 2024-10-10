
FROM registry.access.redhat.com/ubi8/php-82:1-30



# Switch to root for installation
USER 0

# Install necessary packages
RUN dnf -y module enable php:8.2 && \
    dnf install -y --setopt=tsflags=nodocs \
    php-fpm \
    php-mysqlnd \
    php-pgsql \
    php-bcmath \
    php-gd \
    php-intl \
    php-ldap \
    php-mbstring \
    php-pdo \
    php-process \
    php-soap \
    php-opcache \
    php-xml \
    php-gmp \
    php-pecl-apcu \
    php-pecl-zip \
    nginx \
	nano \
    && dnf clean all

# Create necessary directories with correct permissions
RUN mkdir -p /var/www/html \
    /var/run/php-fpm \
    /var/lib/php/session \
    /var/lib/php/wsdlcache \
    /var/lib/php/opcache \
    /var/run/nginx \
    /var/lib/nginx \
    /var/log/nginx \
    /var/log/php-fpm

# Set working directory
WORKDIR /var/www/html

# Copy application files
COPY --chown=1001:0 . .

# Install Composer dependencies
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN composer install --no-dev --optimize-autoloader

# Configure permissions for OpenShift
RUN chgrp -R 0 /var/www/html && \
    chmod -R g=u /var/www/html && \
    chmod -R 775 storage bootstrap/cache && \
    chown -R 1001:0 /var/run/php-fpm && \
    chown -R 1001:0 /var/lib/php && \
    chown -R 1001:0 /var/run/nginx && \
    chown -R 1001:0 /var/lib/nginx && \
    chown -R 1001:0 /var/log/nginx && \
    chown -R 1001:0 /var/log/php-fpm && \
    chmod -R g=u /var/run/php-fpm && \
    chmod -R g=u /var/lib/php && \
    chmod -R g=u /var/run/nginx && \
    chmod -R g=u /var/lib/nginx && \
    chmod -R g=u /var/log/nginx && \
    chmod -R g=u /var/log/php-fpm && \
	chmod -R 775 /opt/app-root/src/.config/

	

# Create PHP-FPM configuration
RUN echo '[global]' > /etc/php-fpm.d/www.conf && \
    echo 'pid = /var/run/php-fpm/php-fpm.pid' >> /etc/php-fpm.d/www.conf && \
    echo 'error_log = /var/log/php-fpm/error.log' >> /etc/php-fpm.d/www.conf && \
    echo '[www]' >> /etc/php-fpm.d/www.conf && \
    echo 'listen = 127.0.0.1:9000' >> /etc/php-fpm.d/www.conf && \
    echo 'listen.allowed_clients = 127.0.0.1' >> /etc/php-fpm.d/www.conf && \
    echo 'pm = dynamic' >> /etc/php-fpm.d/www.conf && \
    echo 'pm.max_children = 50' >> /etc/php-fpm.d/www.conf && \
    echo 'pm.start_servers = 5' >> /etc/php-fpm.d/www.conf && \
    echo 'pm.min_spare_servers = 5' >> /etc/php-fpm.d/www.conf && \
    echo 'pm.max_spare_servers = 35' >> /etc/php-fpm.d/www.conf && \
    echo 'php_admin_value[error_log] = /var/log/php-fpm/www-error.log' >> /etc/php-fpm.d/www.conf && \
    echo 'php_admin_flag[log_errors] = on' >> /etc/php-fpm.d/www.conf && \
    echo 'clear_env = no' >> /etc/php-fpm.d/www.conf

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Create and set up the start script with proper line endings
RUN echo '#!/bin/sh' > /var/www/html/start.sh && \
    echo 'php-fpm -F --fpm-config /etc/php-fpm.d/www.conf -c /etc/php.ini &' >> /var/www/html/start.sh && \
    echo 'nginx -g "daemon off;"' >> /var/www/html/start.sh && \
    chmod +x /var/www/html/start.sh


# Switch to non-root user
USER 1001

# Expose port 8080 (OpenShift preferred)
EXPOSE 8080

# Start services using the shell script
CMD ["/var/www/html/start.sh"]