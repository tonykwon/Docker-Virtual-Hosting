FROM php:alpine
MAINTAINER Tony Kwon <"tonykwon78@gmail.com">

# install the PHP extensions we need
RUN apk upgrade --update \
    && apk --no-cache add freetype-dev libpng-dev libjpeg-turbo-dev libmcrypt-dev libxml2-dev autoconf g++ imagemagick-dev libtool make pcre-dev zip unzip \
    && docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-png-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && /bin/ln -s /usr/bin/zip   /usr/local/bin/zip   \
    && /bin/ln -s /usr/bin/unzip /usr/local/bin/unzip \
    && docker-php-ext-install   gd mbstring mysqli opcache soap iconv \
    && pecl install imagick && docker-php-ext-enable imagick \
#   && pecl install xdebug  && docker-php-ext-enable xdebug  \
    && apk del autoconf file g++ libtool gcc binutils isl libatomic libc-dev musl-dev make re2c binutils-libs mpc1 mpfr3 freetype-dev libjpeg-turbo-dev libxml2-dev \
    && rm -rf /tmp/* /usr/share/man /usr/src/*