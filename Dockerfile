FROM php:7.2.12-apache-stretch

MAINTAINER Maurizio Brioschi <maurizio.brioschi@burda.com>

RUN apt-get update && apt-get install -y \
    		libfreetype6-dev \
    		libjpeg62-turbo-dev \
    		libpng-dev \
    		libmemcached-dev zlib1g-dev \
    		mysql-client \
    		aptitude \
    	&& pecl install memcached-3.0.4 xdebug-2.6.1 \
        && docker-php-ext-enable memcached xdebug \
    	&& docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    	&& docker-php-ext-install -j$(nproc) iconv  mysqli pdo pdo_mysql opcache gd \
    	&& rm -r /var/lib/apt/lists/*

RUN sed -i -e 's/^#\(Include .*httpd-ssl.conf\)/\1/' \
        -e 's/^#\(LoadModule .*mod_ssl.so\)/\1/' \
        -e 's/^#\(LoadModule .*mod_socache_shmcb.so\)/\1/' \
        /etc/apache2/apache2.confpw

RUN aptitude update && aptitude install -y imagemagick

COPY conf/php.ini /usr/local/etc/php/conf.d/php.ini
COPY conf/drupal.conf /etc/apache2/sites-available/000-default.conf
COPY conf/project.dev.crt /usr/local/share/ca-certificates/project.dev.crt
COPY conf/project.dev.pem /usr/local/share/ca-certificates/project.dev.pem
COPY conf/xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini


RUN a2enmod ssl rewrite