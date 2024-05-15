FROM public.ecr.aws/docker/library/php:7.4-apache

# Set ENV variables 
# Update DB connection to point to a K8s service named mysql-service.

ENV DB_HOST mysql-service
ENV DB_USER ecomuser
ENV DB_PASSWORD ecompassword
ENV DB_NAME ecomdb
ENV DB_PORT=3306

# Install mysqli extension for PHP
RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli

# Copy the application source code to /var/www/html/
COPY /ecommerce-app /var/www/html/

# Point DB connection strings mysql-service
RUN sed -i 's/172.20.1.101/mysql-service/g' /var/www/html/index.php

# Expose port 80 to allow traffic to the web server
EXPOSE 80
