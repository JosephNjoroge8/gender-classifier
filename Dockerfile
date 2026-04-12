FROM php:8.2-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    libzip-dev \
    zip \
    unzip \
    sqlite3 \
    libsqlite3-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd zip pdo pdo_sqlite \
    && rm -rf /var/lib/apt/lists/*

# Enable Apache rewrite module
RUN a2enmod rewrite

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy application files
COPY . .

# Install PHP dependencies
RUN composer install --optimize-autoloader --no-dev --no-interaction

# Generate app key
RUN php artisan key:generate --force

# Run migrations
RUN php artisan migrate --force --no-interaction

# Set permissions
RUN chown -R www-data:www-data /var/www/html

# Configure Apache document root
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf

# Create .htaccess for Laravel routing
RUN echo '<Directory /var/www/html/public> \
    Options Indexes FollowSymLinks \
    AllowOverride All \
    Require all granted \
    <IfModule mod_rewrite.c> \
        RewriteEngine On \
        RewriteCond %{REQUEST_FILENAME} !-d \
        RewriteCond %{REQUEST_FILENAME} !-f \
        RewriteRule ^ index.php [L] \
    </IfModule> \
</Directory>' >> /etc/apache2/apache2.conf

# Expose port
EXPOSE 80

CMD ["apache2-foreground"]
