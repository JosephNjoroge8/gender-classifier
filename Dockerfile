FROM php:8.4-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    sqlite3 libsqlite3-dev \
    && docker-php-ext-install pdo pdo_sqlite \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copy and install dependencies
COPY composer.json composer.lock ./
RUN composer install \
    --no-dev --no-interaction --prefer-dist --optimize-autoloader

# Copy application
COPY . .

# Set permissions
RUN mkdir -p storage/logs && chmod -R 777 storage bootstrap/cache

# Expose port
EXPOSE ${PORT:-8000}

# Start PHP built-in server
CMD ["sh", "-c", "php -S 0.0.0.0:${PORT:-8000} -t public"]
FROM php:8.4-apache

# Install dependencies
RUN apt-get update && apt-get install -y \
    sqlite3 libsqlite3-dev git unzip \
    && docker-php-ext-install pdo pdo_sqlite \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set working directory
WORKDIR /var/www/html

# Copy composer files first (for layer caching)
COPY composer.json composer.lock ./

# Run composer install (PHP 8.4 compatible)
RUN composer install \
    --no-dev --no-interaction --prefer-dist --optimize-autoloader

# Copy application code
COPY . .

# Enable Apache modules
RUN a2enmod rewrite

# Set document root
RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/public|' /etc/apache2/sites-available/000-default.conf

# Configure Apache to listen on PORT env var (default 8080 for Cloud Run)
ENV PORT=8080
RUN sed -i "s/Listen 80/Listen \${PORT}/" /etc/apache2/ports.conf

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html && chmod -R 755 /var/www/html

# Start Apache
CMD ["apache2-foreground"]

# Configure Laravel routing
RUN echo '<Directory /var/www/html/public>\n\
    AllowOverride All\n\
    Require all granted\n\
    <IfModule mod_rewrite.c>\n\
        RewriteEngine On\n\
        RewriteCond %{REQUEST_FILENAME} !-f\n\
        RewriteCond %{REQUEST_FILENAME} !-d\n\
        RewriteRule ^ index.php [L]\n\
    </IfModule>\n\
</Directory>' > /etc/apache2/conf-available/laravel.conf && a2enconf laravel

# Set permissions
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80
CMD ["apache2-foreground"]
