FROM php:8.4-cli

RUN apt-get update && apt-get install -y \
    git curl libpng-dev libonig-dev \
    libxml2-dev libzip-dev zip unzip nodejs npm

RUN docker-php-ext-install mbstring xml bcmath pdo zip fileinfo

RUN pecl install mongodb && docker-php-ext-enable mongodb

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /app

COPY . .

RUN mkdir -p storage/framework/sessions \
    storage/framework/views \
    storage/framework/cache \
    storage/logs \
    bootstrap/cache \
    && chmod -R 777 storage bootstrap/cache

RUN composer install --optimize-autoloader --no-dev --no-interaction

RUN npm install && npm run build

EXPOSE 8000

CMD php artisan config:cache && php artisan serve --host=0.0.0.0 --port=${PORT:-8000}
CMD echo "Starting on port: ${PORT}" && \
    php artisan config:cache && \
    php artisan serve --host=0.0.0.0 --port=${PORT:-8000}
