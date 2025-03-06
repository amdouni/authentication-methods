# Dockerfile (docker/Dockerfile)
FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    vim \
    sudo \
    npm \
    nodejs

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd intl zip

# Install Redis extension
RUN pecl install redis && docker-php-ext-enable redis

# Install Composer globally
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install Symfony CLI
RUN curl -sS https://get.symfony.com/cli/installer | bash
RUN mv /root/.symfony5/bin/symfony /usr/local/bin/symfony

# Add a non-root user with sudo privileges
RUN useradd -m -s /bin/bash developer && \
    echo "developer ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/developer

# Set working directory
WORKDIR /var/www/html

# Install Node.js and Yarn
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g yarn

# Configure PHP for development
RUN cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini && \
    echo "memory_limit = 512M" >> /usr/local/etc/php/php.ini && \
    echo "max_execution_time = 60" >> /usr/local/etc/php/php.ini && \
    echo "upload_max_filesize = 20M" >> /usr/local/etc/php/php.ini && \
    echo "post_max_size = 20M" >> /usr/local/etc/php/php.ini

# Install Xdebug (only for development)
RUN pecl install xdebug && \
    docker-php-ext-enable xdebug && \
    echo "xdebug.mode=debug" >> /usr/local/etc/php/php.ini && \
    echo "xdebug.client_host=host.docker.internal" >> /usr/local/etc/php/php.ini && \
    echo "xdebug.start_with_request=yes" >> /usr/local/etc/php/php.ini

# Expose port 8000 for Symfony
EXPOSE 8000

# Set up entrypoint script
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Default command
CMD ["symfony", "server:start", "--port=8000", "--no-tls", "--allow-http", "--no-tls"]

---
# entrypoint.sh (docker/entrypoint.sh)
#!/bin/bash
set -e

# Ensure proper permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html/var

# Wait for database
echo "Waiting for database to be ready..."
ATTEMPTS=0
MAX_ATTEMPTS=30
until mysql -h database -u app_user -papp_password -e "SELECT 1" >/dev/null 2>&1 || [ $ATTEMPTS -eq $MAX_ATTEMPTS ]; do
  ATTEMPTS=$((ATTEMPTS+1))
  echo "Waiting for database connection... $ATTEMPTS/$MAX_ATTEMPTS"
  sleep 1
done

# If database failed to connect
if [ $ATTEMPTS -eq $MAX_ATTEMPTS ]; then
  echo "Database connection could not be established."
  exit 1
fi

# Run Composer install if needed
if [ ! -d "/var/www/html/vendor" ]; then
  echo "Running composer install..."
  composer install --no-interaction
fi

# Run database migrations if needed
echo "Running database migrations..."
php bin/console doctrine:migrations:migrate --no-interaction || true

# Run fixtures if needed in dev environment
if [ "$APP_ENV" = "dev" ]; then
  echo "Loading fixtures..."
  php bin/console doctrine:fixtures:load --no-interaction --append || true
fi

# Clear cache
echo "Clearing cache..."
php bin/console cache:clear

# Change ownership
chown -R www-data:www-data /var/www/html

exec "$@"
