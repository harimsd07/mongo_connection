FROM php:8.4-cli

# Install system dependencies and clean up in one layer
RUN apt-get update && apt-get install -y \
    git curl libpng-dev libonig-dev \
    libxml2-dev libzip-dev zip unzip nodejs npm \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install mbstring xml bcmath pdo zip fileinfo
RUN pecl install mongodb && docker-php-ext-enable mongodb

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /app

# Copy dependency manifests first for better layer caching
COPY composer.json composer.lock ./
RUN composer install --optimize-autoloader --no-dev --no-interaction --no-scripts

COPY package.json package-lock.json ./
RUN npm ci

# Now copy the rest of the application
COPY . .

# Run composer scripts now that full app is present
RUN composer run-script post-autoload-dump 2>/dev/null || true

RUN npm run build

# Set up storage directories with safe permissions
RUN mkdir -p storage/framework/sessions \
    storage/framework/views \
    storage/framework/cache \
    storage/logs \
    bootstrap/cache \
  && chmod -R 755 storage bootstrap/cache

# Cache config at build time (requires .env or env vars to be set)
# RUN php artisan config:cache

# Create a non-root user and switch to it
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 8000

CMD php artisan config:cache && php artisan serve --host=0.0.0.0 --port=${PORT:-8000}
