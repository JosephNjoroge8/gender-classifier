FROM php:8.2-cli AS composer

# Install necessary tools for composer
RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy composer files
COPY composer.json composer.lock* ./

# Install dependencies with memory limit and clear cache
ENV COMPOSER_MEMORY_LIMIT=-1
RUN composer install \
    --optimize-autoloader \
    --no-dev \
    --no-interaction \
    --no-cache \
    --prefer-dist

# ============================================================

FROM php:8.2-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    sqlite3 \
    libsqlite3-dev \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_sqlite

# Enable Apache rewrite module
RUN a2enmod rewrite headers

# Set working directory
WORKDIR /var/www/html

# Copy vendor from builder image
COPY --from=composer /app/vendor ./vendor
COPY --from=composer /app/composer.lock ./composer.lock 2>/dev/null || true

# Copy entire application
COPY . .

# Create necessary directories
RUN mkdir -p database storage/app storage/framework/cache storage/framework/sessions storage/logs bootstrap/cache

# Create SQLite database
RUN touch database/database.sqlite

# Set permissions
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 775 storage bootstrap/cache database

# Generate app key if .env doesn't exist
RUN if [ ! -f .env ]; then cp .env.example .env 2>/dev/null || echo "APP_KEY=base64:a9nK5p2mL6x8vQ4rX1yT3fG7hJ9bN0dM2sW5cZ8kP1q=\nAPP_ENV=production\nAPP_DEBUG=false" > .env; fi

# Generate app key
RUN php artisan key:generate --force 2>/dev/null || true

# Run migrations
RUN php artisan migrate --force --no-interaction 2>/dev/null || true

# Configure Apache document root
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf

# Laravel routing configuration
RUN echo '<Directory /var/www/html/public> \
    Options -MultiViews -Indexes +FollowSymLinks \
    AllowOverride All \
    Require all granted \
    <IfModule mod_rewrite.c> \
        RewriteEngine On \
        RewriteCond %{REQUEST_FILENAME} !-d \
        RewriteCond %{REQUEST_FILENAME} !-f \
        RewriteRule ^ index.php [L] \
    </IfModule> \
</Directory>' >> /etc/apache2/apache2.conf

# Add security headers
RUN echo "Header set Access-Control-Allow-Origin \"*\"" >> /etc/apache2/apache2.conf

EXPOSE 80

CMD ["apache2-foreground"]
