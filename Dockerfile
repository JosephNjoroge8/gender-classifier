FROM php:8.4-cli

# Install system dependencies (SQLite for database)
RUN apt-get update && apt-get install -y \
    sqlite3 libsqlite3-dev git unzip \
    && docker-php-ext-install pdo pdo_sqlite \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set working directory
WORKDIR /app

# Copy composer files
COPY composer.json composer.lock ./

# Install PHP dependencies (without dev dependencies)
RUN composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader

# Copy entire application
COPY . .

# Create necessary Laravel directories
RUN mkdir -p storage/logs bootstrap/cache && chmod -R 777 storage bootstrap/cache database

# Expose the port (Fly.io expects 8080, but we'll use PORT env var if set)
EXPOSE 8080

# Start PHP built-in server using PORT env var (defaults to 8080)
# Fly.io sets PORT=8080 automatically
CMD sh -c "php -S 0.0.0.0:${PORT:-8080} -t public"
