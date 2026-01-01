FROM wordpress:php8.2-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    vim \
    libzip-dev \
    zip \
    && rm -rf /var/lib/apt/lists/*

# Install IonCube Loader with auto-detect PHP version
RUN cd /tmp \
    && PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;") \
    && wget -q https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz \
    && tar xzf ioncube_loaders_lin_x86-64.tar.gz \
    && PHP_EXT_DIR=$(php-config --extension-dir) \
    && cp ioncube/ioncube_loader_lin_${PHP_VERSION}.so ${PHP_EXT_DIR}/ \
    && echo "zend_extension=ioncube_loader_lin_${PHP_VERSION}.so" > /usr/local/etc/php/conf.d/00-ioncube.ini \
    && rm -rf /tmp/ioncube*

# Configure PHP settings for WordPress
RUN { \
    echo 'upload_max_filesize = 128M'; \
    echo 'post_max_size = 128M'; \
    echo 'memory_limit = 256M'; \
    echo 'max_execution_time = 300'; \
    echo 'max_input_vars = 3000'; \
    echo 'max_input_time = 300'; \
    } > /usr/local/etc/php/conf.d/wordpress.ini

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html

# Verify installations
RUN php -v && \
    php -m | grep -i ioncube && \
    which wget && \
    which unzip && \
    which vim

WORKDIR /var/www/html

EXPOSE 80
