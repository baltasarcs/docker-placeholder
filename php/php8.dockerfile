FROM php:8.1-fpm

# Arguments in docker-compose.yml
ARG user
ARG uid

# Set working directory
WORKDIR /var/www/placeholder

# Install dependencies
RUN apt-get update && apt-get install -y \
    apt-utils \
    curl \
    libssl-dev \
    openssl \
    git \
    unzip \
    libzip-dev \
    libxml2-dev \
    libxslt-dev \
    libonig-dev \
    libpq-dev \
    imagemagick

# Install extensions
RUN docker-php-ext-install mysqli pdo pdo_mysql pdo_pgsql session xml zip iconv simplexml mbstring phar soap

# Install gd and requirements
RUN apt-get install -y --no-install-recommends libpng-dev libjpeg62-turbo-dev libfreetype6-dev && \
    docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ && \
    docker-php-ext-install gd

# Install redis
RUN pecl install -o -f redis && rm -rf /tmp/pear && docker-php-ext-enable redis

# Install xdebug
RUN pecl install xdebug && docker-php-ext-enable xdebug

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Create system user non-root to run Composer and Artisan Commands
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

# Change current user to www
USER $user

# Expose port 9000 and start php-fpm server
EXPOSE 9000

CMD ["php-fpm"]
