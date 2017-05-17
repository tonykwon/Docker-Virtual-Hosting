FROM php:fpm-alpine
MAINTAINER Tony Kwon <"tonykwon78@gmail.com">

# install the PHP extensions we need
RUN apk upgrade --update \
    && apk add freetype-dev libpng-dev libjpeg-turbo-dev libmcrypt-dev libxml2-dev autoconf g++ imagemagick-dev libtool make pcre-dev \
    && docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-png-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install   gd mbstring mysqli opcache soap iconv mcrypt \
    && pecl install imagick && docker-php-ext-enable imagick \
    && pecl install xdebug  && docker-php-ext-enable xdebug \
    && apk del autoconf file g++ libtool gcc binutils isl libatomic libc-dev musl-dev make re2c libstdc++ libgcc binutils-libs mpc1 mpfr3 gmp libgomp \
    && rm -rf /var/cache/apk/* /tmp/* /usr/share/man

# use "volumes" feature of docker-compose.yml instead of COPY