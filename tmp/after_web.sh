#!/bin/bash

sed -i 's/^Listen.*/Listen 8080/g' /etc/apache2/conf/ports.conf
chkconfig --level 2345 nginx on
chkconfig --level 2345 apache on
initctl reload-configuration
rm -f /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/ckan /etc/nginx/sites-enabled/ckan
a2dissite default
a2ensite ckan


service apache2 restart
service nginx restart
