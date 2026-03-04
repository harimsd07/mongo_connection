FROM php:8.4-cli

RUN apt-get update && apt-get install -y \
    git curl libpng-dev libonig-dev \
    libxml2-dev libzip-dev zip unzip nodejs npm

RUN docker-php-ext-install mbstring xml bcmath pdo zip fileinfo

RUN pecl config-set php_ini /usr/local/etc/php/php.ini && \
    mkdir -p /tmp/mongodb-src && \
    curl -L --retry 5 --retry-delay 3 -o /tmp/mongodb-src/mongodb.tgz \
    https://pecl.php.net/get/mongodb && \
    pecl install /tmp/mongodb-src/mongodb.tgz && \
    docker-php-ext-enable mongodb && \
    rm -rf /tmp/mongodb-src

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

CMD echo "Starting on port: ${PORT:-8000}" && \
    php artisan config:cache && \
    php artisan serve --host=0.0.0.0 --port=${PORT:-8000}
