FROM php:7.3-apache

RUN apt-get update && apt-get install -y \
    libicu-dev \
    libpng-dev \
    libjpeg-dev \
    libpq-dev \
    libzip-dev \
    unzip \
    git \
    && docker-php-ext-configure gd --with-jpeg-dir=/usr/lib \
    && docker-php-ext-install -j$(nproc) gd intl zip pdo pdo_mysql mysqli

ENV MEDIAWIKI_VERSION=1.35

RUN curl -SL "https://releases.wikimedia.org/mediawiki/$MEDIAWIKI_VERSION/mediawiki-$MEDIAWIKI_VERSION.tar.gz" -o mediawiki.tar.gz \
    && tar -xz --strip-components=1 -f mediawiki.tar.gz -C /var/www/html \
    && rm mediawiki.tar.gz \
    && chown -R www-data:www-data /var/www/html

COPY config/LocalSettings.php /var/www/html/

ENV MEDIAWIKI_DB_HOST=db
ENV MEDIAWIKI_DB_NAME=my_wiki
ENV MEDIAWIKI_DB_USER=wikiuser
ENV MEDIAWIKI_DB_PASSWORD=wikipass

RUN sed -i "s/\$wgDBuser.*/\$wgDBuser = '$MEDIAWIKI_DB_USER';/g" /var/www/html/LocalSettings.php \
    && sed -i "s/\$wgDBpassword.*/\$wgDBpassword = '$MEDIAWIKI_DB_PASSWORD';/g" /var/www/html \
    && sed -i "s/\$wgDBname.*/\$wgDBname = '$MEDIAWIKI_DB_NAME';/g" /var/www/html \
    && sed -i "s/\$wgDBserver.*/\$wgDBserver = '$MEDIAWIKI_DB_HOST';/g" /var/www/html

COPY config/config.php /var/www/html/

EXPOSE 80

CMD ["apache2-foreground"]