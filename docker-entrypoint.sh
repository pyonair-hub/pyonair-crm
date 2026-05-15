#!/bin/bash
set -e

# Generate app key if not set
if [ -z "$APP_KEY" ]; then
    php artisan key:generate --force
fi

# Create storage symlink
php artisan storage:link --force 2>/dev/null || true

# Run migrations (with retry for DB startup delay)
max_tries=10
count=0
until php artisan migrate --force 2>/dev/null; do
    count=$((count + 1))
    if [ $count -ge $max_tries ]; then
        echo "WARNING: Could not run migrations after $max_tries attempts"
        break
    fi
    echo "Waiting for database... attempt $count/$max_tries"
    sleep 3
done

# Seed if first run (check if users table is empty)
php artisan db:seed --force 2>/dev/null || true

# Cache config and routes for production
php artisan config:cache
php artisan route:cache
php artisan view:cache

exec "$@"
