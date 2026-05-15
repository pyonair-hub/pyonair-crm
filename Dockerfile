# Stage 1: Composer dependencies
FROM php:8.2-cli-alpine AS composer-stage
RUN apk add --no-cache git zip unzip curl libpng-dev libjpeg-turbo-dev freetype-dev \
    icu-dev oniguruma-dev libxml2-dev postgresql-dev
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install pdo pdo_mysql pdo_pgsql bcmath gd intl mbstring xml pcntl
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
WORKDIR /app
COPY . .
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Stage 2: Frontend build
FROM node:22-alpine AS frontend-stage
WORKDIR /app
COPY . .
# Create a minimal .env so vite loadEnv doesn't fail
RUN echo "APP_NAME='Pyonair CRM'" > .env
RUN npm install
# Build main assets, admin, installer, webform
RUN npx vite build || true
RUN cd packages/Webkul/Admin && npx vite build || true
RUN cd packages/Webkul/Installer && npx vite build || true
RUN cd packages/Webkul/WebForm && npx vite build || true

# Stage 3: Production image
FROM php:8.2-apache

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpng-dev libjpeg-dev libfreetype6-dev libicu-dev libonig-dev \
    libxml2-dev libpq-dev libzip-dev unzip curl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql pdo_pgsql bcmath gd intl mbstring xml pcntl zip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Apache config
RUN a2enmod rewrite headers
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}/!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# PHP production config
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
RUN echo "memory_limit=256M" >> "$PHP_INI_DIR/php.ini"
RUN echo "upload_max_filesize=64M" >> "$PHP_INI_DIR/php.ini"
RUN echo "post_max_size=64M" >> "$PHP_INI_DIR/php.ini"

WORKDIR /var/www/html

# Copy application from composer stage
COPY --from=composer-stage /app .

# Copy built frontend assets (use shell to handle missing dirs)
RUN rm -rf public/build public/admin/build
COPY --from=frontend-stage /app/public/ ./public/

# Set permissions
RUN chown -R www-data:www-data storage bootstrap/cache
RUN chmod -R 775 storage bootstrap/cache

# Copy entrypoint
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 80

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]
