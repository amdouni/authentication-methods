# Base image with PHP 8.3
FROM mcr.microsoft.com/devcontainers/php:8.3-bullseye

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git zip unzip curl \
    libpq-dev libpng-dev libjpeg-dev libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_pgsql pdo_mysql

# Install Symfony CLI
RUN curl -sS https://get.symfony.com/cli/installer | bash && mv /root/.symfony5/bin/symfony /usr/local/bin/symfony

# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Node.js and Yarn
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    if ! command -v yarn > /dev/null; then npm install -g yarn; fi
# Xdebug for debugging
RUN if ! php -m | grep -q xdebug; then pecl install xdebug && docker-php-ext-enable xdebug; fi



# Définir le dossier de travail
WORKDIR /workspace/auth-methods

# Expose ports
EXPOSE 8000 5432

CMD ["symfony", "server:start"]
