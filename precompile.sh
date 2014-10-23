#!/usr/bin/env bash
set -e

APACHE_VERSION=2.4.10
PHP_VERSION=5.6.2
APACHE_URL=http://www.us.apache.org/dist/httpd/httpd-$APACHE_VERSION.tar.gz
APR_URL=http://www.us.apache.org/dist/apr/apr-1.5.1.tar.gz
APR_UTIL_URL=http://www.us.apache.org/dist/apr/apr-util-1.5.4.tar.gz
PHP_URL=http://us1.php.net/get/php-$PHP_VERSION.tar.gz/from/this/mirror

# Install all the dependencies
apt-get install libxml2 libxml2-dev libssl-dev libvpx-dev libjpeg-dev \
  libpng-dev libXpm-dev libbz2-dev libmcrypt-dev libcurl4-openssl-dev \
  libfreetype6-dev postgresql-server-dev-8.4 libpcre3 libpcre3-dev curl \
  autoconf libmysqlclient-dev

mkdir -p /tmp/build
pushd /tmp/build
  mkdir -p apache apr apr-util php
  curl -L $APACHE_URL | tar xz --strip-components=1 -C apache
  curl -L $APR_URL | tar xz --strip-components=1 -C apr
  curl -L $APR_UTIL_URL | tar xz --strip-components=1 -C apr-util
  curl -L $PHP_URL | tar xz --strip-components=1 -C php

  # compile apache
  mv apr apache/srclib/
  mv apr-util apache/srclib/
  pushd apache
    ./configure --prefix=/app/apache --with-included-apr --enable-rewrite
    make
    make install
  popd

  # apache libraries
  mkdir -p /app/php/ext
  cp /app/apache/lib/libapr-1.so.0 /app/php/ext
  cp /app/apache/lib/libaprutil-1.so.0 /app/php/ext
  pushd /app/php/ext
    ln -s libapr-1.so.0 libapr-1.so
    ln -s libaprutil-1.so.0 libaprutil-1.so
  popd

  # php
  pushd php
    ./configure --prefix=/app/php --with-apxs2=/app/apache/bin/apxs \
      --with-mysql --with-pdo-mysql --with-pgsql --with-pdo-pgsql --with-iconv \
      --with-gd --with-curl=/usr/lib --with-config-file-path=/app/php \
      --enable-soap=shared --enable-libxml --enable-simplexml --enable-session \
      --with-xmlrpc --with-openssl --enable-mbstring --with-bz2 --with-zlib \
      --with-gd --with-freetype-dir=/usr/lib --with-jpeg-dir=/usr/lib \
      --with-png-dir=/usr/lib --with-xpm-dir=/usr/lib
    make
    make install
  popd

  # php extensions
  pushd /app/php/ext
    cp /usr/lib/libmysqlclient.so.16.0.0 .
    ln -s libmysqlclient.so.16.0.0 libmysqlclient.so.16
    ln -s libmysqlclient.so.16.0.0 libmysqlclient.so
  popd

  # apache php module
  cp php/.libs/libphp5.so /app/apache/modules/

  pushd /app
    echo $APACHE_VERSION > apache/VERSION
    tar -zcvf apache-$APACHE_VERSION.tar.gz apache

    echo $PHP_VERSION > php/VERSION
    tar -zcvf php-$PHP_VERSION.tar.gz php
  popd
popd