FROM php:8.2-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    sqlite3 \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_sqlite

# Enable Apache modules
RUN a2enmod rewrite

# Set working directory
WORKDIR /var/www/html

# Copy entire application (vendor already built locally)
COPY . .

# Create necessary directories
RUN mkdir -p database storage/logs bootstrap/cache

# Create SQLite database file
RUN touch database/database.sqlite

# Set permissions
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 storage bootstrap/cache database

# Copy .env if not present
RUN if [ ! -f .env ]; then cp .env.example .env; fi

# Configure Apache document root
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/000-default.conf

# Configure Laravel rewrite rules
RUN echo '<Directory /var/www/html/public> \
    AllowOverride All \
    Require all granted \
    <IfModule mod_rewrite.c> \
        RewriteEngine On \
        RewriteCond %{REQUEST_FILENAME} !-d \
        RewriteCond %{REQUEST_FILENAME} !-f \
        RewriteRule ^ index.php [L] \
    </IfModule> \
</Directory>' > /etc/apache2/conf-available/laravel.conf && \
    a2enconf laravel

EXPOSE 80

CMD ["apache2-foreground"]
