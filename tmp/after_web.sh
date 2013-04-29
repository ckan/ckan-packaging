#!/bin/bash

sed -i 's/^Listen.*/Listen 8080/g' /etc/apache2/conf/ports.conf
chkconfig --level 2345 nginx on
chkconfig --level 2345 apache on
initctl reload-configuration
rm -f /etc/nginx/sites-enabled/default
rm -f /etc/apache2/sites-enabled/000-default

service apache2 restart
service nginx restart
