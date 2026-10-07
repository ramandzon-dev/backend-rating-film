#!/bin/bash
set -e

# Railway provides dynamic PORT environment variable (e.g. 8080, 3000)
PORT="${PORT:-80}"

echo "==> Configuring Apache port to ${PORT}..."
sed -i "s/Listen [0-9]*/Listen ${PORT}/g" /etc/apache2/ports.conf
sed -i "s/<VirtualHost \*:[0-9]*>/<VirtualHost \*:${PORT}>/g" /etc/apache2/sites-available/000-default.conf

# Setup SQLite database if DB_CONNECTION is sqlite or not specified
if [ "${DB_CONNECTION:-sqlite}" = "sqlite" ]; then
    echo "==> Ensuring SQLite database exists..."
    mkdir -p /var/www/html/database
    if [ ! -f /var/www/html/database/database.sqlite ]; then
        touch /var/www/html/database/database.sqlite
    fi
    chown -R www-data:www-data /var/www/html/database
    chmod -R 775 /var/www/html/database
fi

# Set proper permissions for Laravel writable directories
mkdir -p /var/www/html/storage/logs \
         /var/www/html/storage/framework/sessions \
         /var/www/html/storage/framework/views \
         /var/www/html/storage/framework/cache/data \
         /var/www/html/bootstrap/cache
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Generate APP_KEY if not already set
if [ -z "$APP_KEY" ]; then
    echo "==> APP_KEY is empty, generating key..."
    php artisan key:generate --force
fi

# Clear old cached files
php artisan config:clear || true
php artisan route:clear || true
php artisan view:clear || true

# Run database migrations
echo "==> Running migrations..."
php artisan migrate --force || echo "==> Migrations failed or database not ready."

if [ "${DB_SEED:-false}" = "true" ]; then
    echo "==> Seeding database..."
    php artisan db:seed --force || echo "==> Seeding failed."
fi

# Cache configurations for production speed
php artisan config:cache || true
php artisan route:cache || true

echo "==> Starting Apache on port ${PORT}..."
exec apache2-foreground
