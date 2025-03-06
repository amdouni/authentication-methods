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
