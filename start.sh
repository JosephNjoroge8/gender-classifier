#!/bin/bash
set -eo pipefail

echo "Installing PHP dependencies..."
composer install --no-dev --optimize-autoloader

echo "Starting PHP development server on port ${PORT:-8000}..."
php -S 0.0.0.0:${PORT:-8000} -t public/
