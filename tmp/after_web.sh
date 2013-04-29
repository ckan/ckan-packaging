#!/bin/bash

sed -i 's/^NameVirtualHost.*/NameVirtualHost *:8080/g' /etc/apache2/ports.conf
sed -i 's/^Listen.*/Listen 8080/g' /etc/apache2/ports.conf

if [ ! -f /etc/ckan/production.ini ];
then
	/usr/lib/ckan/bin/paster make-config ckan /etc/ckan/production.ini
	sed -i 's/^# ckan.site_id.*/ckan.site_id = ckan_instance/g' /etc/ckan/production.ini
	sed -i 's/^args = ("ckan.log.*/args = ("\/var\/log\/ckan\/ckan.log", "a", 20000000, 9)/g' /etc/ckan/production.ini
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

if [ -f /etc/apache2/sites-enabled/ckan ];
then
	a2ensite ckan
fi

if [ ! -d /var/log/ckan ];
then
	mkdir /var/log/ckan/
	chown www-data /var/log/ckan
fi

service apache2 restart
service nginx restart
