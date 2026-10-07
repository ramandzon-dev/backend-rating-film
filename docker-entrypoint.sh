#!/bin/bash
set -e

# Railway and modern PaaS provide dynamic PORT environment variable (e.g. 8080, 3000)
PORT="${PORT:-80}"
APACHE_DOCUMENT_ROOT="${APACHE_DOCUMENT_ROOT:-/var/www/html/public}"

echo "==> [Railway Deploy] Setting up container for port: ${PORT}..."

# 1. Cleanly configure Apache listening port (single port only, avoid duplicate port binds)
echo "Listen ${PORT}" > /etc/apache2/ports.conf

# 2. Cleanly configure 000-default VirtualHost
cat <<EOF > /etc/apache2/sites-available/000-default.conf
<VirtualHost *:${PORT}>
    ServerAdmin webmaster@localhost
    DocumentRoot ${APACHE_DOCUMENT_ROOT}

    <Directory ${APACHE_DOCUMENT_ROOT}>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

# 3. Ensure .env exists so artisan commands never fail
if [ ! -f /var/www/html/.env ]; then
    echo "==> Creating .env from .env.example..."
    if [ -f /var/www/html/.env.example ]; then
        cp /var/www/html/.env.example /var/www/html/.env
    else
        touch /var/www/html/.env
    fi
fi

# 4. Handle APP_KEY safely
if [ -n "$APP_KEY" ]; then
    echo "==> Injecting APP_KEY from environment..."
    grep -q "^APP_KEY=" /var/www/html/.env && sed -i "s|^APP_KEY=.*|APP_KEY=${APP_KEY}|" /var/www/html/.env || echo "APP_KEY=${APP_KEY}" >> /var/www/html/.env
else
    echo "==> Generating fresh APP_KEY..."
    php artisan key:generate --force || true
fi

# 5. Database setup: default to SQLite if not using external MySQL/PostgreSQL
DB_CONNECTION="${DB_CONNECTION:-sqlite}"
echo "==> Active DB_CONNECTION: ${DB_CONNECTION}"

if [ "$DB_CONNECTION" = "sqlite" ]; then
    echo "==> Ensuring SQLite database directory and file exist..."
    mkdir -p /var/www/html/database
    if [ ! -f /var/www/html/database/database.sqlite ]; then
        touch /var/www/html/database/database.sqlite
    fi
    chown -R www-data:www-data /var/www/html/database
    chmod -R 775 /var/www/html/database
fi

# 6. Set proper permissions for Laravel writable directories
mkdir -p /var/www/html/storage/logs \
         /var/www/html/storage/framework/sessions \
         /var/www/html/storage/framework/views \
         /var/www/html/storage/framework/cache/data \
         /var/www/html/bootstrap/cache
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# 7. Clear old caches
php artisan config:clear || true
php artisan route:clear || true
php artisan view:clear || true

# 8. Run database migrations safely (never crash container if DB takes time to connect)
echo "==> Running database migrations..."
php artisan migrate --force || echo "==> [Notice] Migration failed or database not ready yet."

# 9. Optionally seed database if DB_SEED=true
if [ "${DB_SEED:-false}" = "true" ]; then
    echo "==> Seeding database..."
    php artisan db:seed --force || echo "==> [Notice] Seeding failed or already seeded."
fi

echo "==> Starting Apache web server on port ${PORT}..."
exec apache2-foreground
