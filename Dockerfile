FROM ubuntu:20.04 as intermediate

ENV DEBIAN_FRONTEND noninteractive

RUN apt update && apt install -y wget unzip

RUN    cd /tmp/ \
    && mkdir grav-download \
    && cd grav-download \
    && wget -c https://getgrav.org/download/core/grav-admin/latest \
    && unzip * #\
    #    && rm -rf /var/www/html \
    #    && mv /tmp/grav-download/grav-admin /var/www/html

COPY /tmp/grav-download/grav-admin

FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt update && apt install -y apache2 php-fpm php php-mbstring php-xml php-gd php-curl php-dom php-zip

RUN a2dismod php7.4 mpm_prefork 

RUN a2enconf php7.4-fpm

RUN a2enmod http2 mpm_event proxy_fcgi setenvif rewrite

RUN rm -rf /var/www/html

COPY --from=intermediate /tmp/grav-download/grav-admin /var/www/html

RUN chown -R www-data:www-data /var/www/

RUN echo '<VirtualHost *:80> \n\
	ServerAdmin webmaster@localhost \n\
        DocumentRoot /var/www/html \n\
        ErrorLog ${APACHE_LOG_DIR}/error.log \n\
        CustomLog ${APACHE_LOG_DIR}/access.log combined \n\
        <Directory "/var/www"> \n\
                AllowOverride All \n\
		Options +FollowSymlinks \n\
        </Directory> \n\
	</VirtualHost> \n\
        ' > /etc/apache2/sites-available/000-default.conf

RUN sed -i 's/pm.max_children.*/pm.max_children = 8/g' /etc/php/7.4/fpm/pool.d/www.conf


EXPOSE 80

#VOLUME ['/var/www/html/user/']


CMD ["sh", "-c", "service php7.4-fpm start; /usr/sbin/apache2ctl -DFOREGROUND"]


