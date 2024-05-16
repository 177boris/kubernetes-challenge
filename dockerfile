FROM php:7.4-apache

WORKDIR /var/www/html

# Copy the application source code to /var/www/html/
COPY ./ecommerce-app /var/www/html/

# Install mysqli extension for PHP
RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli 

RUN echo "ServerName 127.0.0.1" >> /etc/apache2/apache2.conf

# Set ENV variables 
# Update DB connection to point to a K8s service named mysql-service.
ENV DB_HOST=mysql-service
ENV DB_USER=ecomuser
ENV DB_PASSWORD=ecompassword
ENV DB_NAME=ecomdb
ENV DB_PORT=3306

# Point DB connection strings mysql-service
RUN sed -i 's/172.20.1.101/${DB_HOST}/g' /var/www/html/index.php

# Expose port 80 to allow traffic to the web server
EXPOSE 80

# Start the Apache web server when the container starts
CMD ["apache2-foreground"]