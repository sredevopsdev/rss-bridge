FROM lwthiker/curl-impersonate:0.5.2-ff-slim-buster AS curlimpersonate

FROM php:8.1.18-fpm AS rssbridge

LABEL description="(Fork of) RSS-Bridge is a PHP project capable of generating RSS and Atom feeds for websites that don't have one."
LABEL repository="https://github.com/sredevopsdev/rss-bridge"
LABEL website="https://github.com/sredevopsdev/rss-bridge"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install --yes --no-install-recommends \
      nginx \
      zlib1g-dev \
      libzip-dev \
      libmemcached-dev \
      nss-plugin-pem \
      libicu-dev && \
      apt autoclean -y

RUN docker-php-ext-install zip && \
    docker-php-ext-install intl && \
    pecl install memcached && \
    docker-php-ext-enable memcached && \
    docker-php-ext-enable opcache && \
    mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

COPY ./config/nginx.conf /etc/nginx/sites-enabled/default

COPY --chown=www-data:www-data ./ /app/

COPY --from=curlimpersonate /usr/local/lib/libcurl-impersonate-ff.so /usr/local/lib/curl-impersonate/

ENV LD_PRELOAD=/usr/local/lib/curl-impersonate/libcurl-impersonate-ff.so

ENV CURL_IMPERSONATE ff91esr

EXPOSE 80

ENTRYPOINT ["/app/docker-entrypoint.sh"]
