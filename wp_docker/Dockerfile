FROM wordpress:latest

RUN mkdir /var/www/Script 

COPY ./backup_restore.sh /var/www/Script/backup_restore.sh

COPY ./init.sh /usr/local/bin/init.sh

RUN chmod +x /var/www/Script/backup_restore.sh && chmod +x /usr/local/bin/init.sh

# For "^M: bad interpreter: No such file or directory" error message
RUN perl -i -pe 'y|\r||d' /usr/local/bin/init.sh \
    && perl -i -pe 'y|\r||d' /var/www/Script/backup_restore.sh

# For the 'Could not reliably determine the server's fully qualified domain name' error
RUN echo "ServerName 127.0.0.1" >> /etc/apache2/apache2.conf

WORKDIR /var/www/html
