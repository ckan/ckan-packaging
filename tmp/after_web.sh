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

CKAN_INSTALL=/usr/lib/ckan/default

for i in $CKAN_INSTALL/src/*
do
    if [ -d $i ] && [ $i != $CKAN_INSTALL/src/ckan ];
    then

        if [ -f $i/pip-requirements.txt ];
        then
            $CKAN_INSTALL/bin/pip install -r $i/pip-requirements.txt
        fi
        if [ -f $i/requirements.txt ];
        then
            $CKAN_INSTALL/bin/pip install -r $i/requirements.txt
        fi
        $CKAN_INSTALL/bin/python  $i/setup.py develop
    fi
done
