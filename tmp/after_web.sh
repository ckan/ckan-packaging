#!/bin/bash

cp --backup=numbered /etc/apache2/ports.conf /etc/apache2/ports.conf.preckan
sed -i 's/^NameVirtualHost.*/NameVirtualHost *:8080/g' /etc/apache2/ports.conf
sed -i 's/^Listen.*/Listen 8080/g' /etc/apache2/ports.conf

if [ ! -f /etc/ckan/default/production.ini ];
then
	/usr/lib/ckan/default/bin/paster make-config ckan /etc/ckan/default/production.ini
fi

update-rc.d nginx defaults
update-rc.d apache2 defaults
initctl reload-configuration

if [ -f /etc/nginx/sites-enabled/default ];
then
	rm -f /etc/nginx/sites-enabled/default
fi

if [ ! -f /etc/nginx/sites-enabled/ckan ];
then
	ln -s /etc/nginx/sites-available/ckan /etc/nginx/sites-enabled/ckan
fi

if [ -f /etc/apache2/sites-enabled/000-default ];
then
	a2dissite default
fi

if [ ! -f /etc/apache2/sites-enabled/ckan_default ];
then
	a2ensite ckan_default
fi

service apache2 restart
service nginx restart
