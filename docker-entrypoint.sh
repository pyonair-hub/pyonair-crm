#!/bin/bash
set -e

# Create .env file from environment variables if it doesn't exist
if [ ! -f /var/www/html/.env ]; then
    cat > /var/www/html/.env <<EOF
APP_NAME="${APP_NAME:-Pyonair CRM}"
APP_ENV="${APP_ENV:-production}"
APP_KEY="${APP_KEY:-}"
APP_DEBUG="${APP_DEBUG:-false}"
APP_URL="${APP_URL:-http://localhost}"
APP_TIMEZONE="${APP_TIMEZONE:-UTC}"
APP_LOCALE="${APP_LOCALE:-en}"
APP_CURRENCY="${APP_CURRENCY:-USD}"

LOG_CHANNEL=stack
LOG_LEVEL=error

DB_CONNECTION="${DB_CONNECTION:-pgsql}"
DB_HOST="${DB_HOST:-127.0.0.1}"
DB_PORT="${DB_PORT:-5432}"
DB_DATABASE="${DB_DATABASE:-pyonair_crm}"
DB_USERNAME="${DB_USERNAME:-}"
DB_PASSWORD="${DB_PASSWORD:-}"
DB_PREFIX="${DB_PREFIX:-}"

BROADCAST_DRIVER=log
CACHE_DRIVER=file
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120
EOF
    chown www-data:www-data /var/www/html/.env
fi

# Generate app key if not set
if [ -z "$APP_KEY" ] || ! grep -q "APP_KEY=base64" /var/www/html/.env; then
    php artisan key:generate --force
fi

# Create storage symlink
php artisan storage:link --force 2>/dev/null || true

# Run migrations (with retry for DB startup delay)
max_tries=15
count=0
until php artisan migrate --force 2>/dev/null; do
    count=$((count + 1))
    if [ $count -ge $max_tries ]; then
        echo "WARNING: Could not run migrations after $max_tries attempts"
        break
    fi
    echo "Waiting for database... attempt $count/$max_tries"
    sleep 5
done

# Seed if first run
php artisan db:seed --force 2>/dev/null || true

# Cache config and routes for production
php artisan config:cache 2>/dev/null || true
php artisan route:cache 2>/dev/null || true
php artisan view:cache 2>/dev/null || true

exec "$@"
