FROM php:8.2-cli AS composer

WORKDIR /app

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy composer files
COPY composer.json composer.lock* ./

# Install dependencies
RUN composer install \
    --optimize-autoloader \
    --no-dev \
    --no-interaction

# ============================================================

FROM php:8.2-apache

# Install only minimal system dependencies
RUN apt-get update && apt-get install -y \
    sqlite3 \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_sqlite

# Enable Apache rewrite module
RUN a2enmod rewrite

# Set working directory
WORKDIR /var/www/html

# Copy vendor from builder image
COPY --from=composer /app/vendor ./vendor

# Copy entire application
COPY . .

# Create SQLite database
RUN mkdir -p database && touch database/database.sqlite

# Generate app key (if not present)
RUN if [ ! -f .env ]; then cp .env.example .env; fi && \
    php artisan key:generate --force || true

# Run migrations
RUN php artisan migrate --force --no-interaction || true

# Set permissions
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 storage bootstrap/cache

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

EXPOSE 80

CMD ["apache2-foreground"]
