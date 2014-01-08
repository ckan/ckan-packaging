#!/bin/bash

cp --backup=numbered /etc/apache2/ports.conf /etc/apache2/ports.conf.preckan

if grep -Fxq 'NameVirtualHost *:80' /etc/apache2/ports.conf
then
    sed -i 's/^NameVirtualHost \*\:80/NameVirtualHost *:8080/g' /etc/apache2/ports.conf
fi

if grep -Fxq 'Listen 80' /etc/apache2/ports.conf
then
    sed -i 's/^Listen 80/Listen 8080/g' /etc/apache2/ports.conf
fi

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
        if [ -f $i/setup.py ];
        then
            cd $i
            $CKAN_INSTALL/bin/python  $i/setup.py develop
        fi
    fi
done

# datapusher
if [ ! -f /etc/apache2/sites-available/datapusher ];
then
	cp /usr/lib/ckan/datapusher/src/datapusher/deployment/datapusher /etc/apache2/sites-available/datapusher
fi

if [ ! -f /etc/apache2/sites-enabled/datapusher ];
then
	a2ensite datapusher
fi

if [ ! -f /etc/ckan/datapusher_settings.py ];
then
	cp /usr/lib/ckan/datapusher/src/datapusher/deployment/datapusher_settings.py /etc/ckan/
fi

cp /usr/lib/ckan/datapusher/src/datapusher/deployment/datapusher.wsgi /etc/ckan/

if ! grep -Fxq 'NameVirtualHost *:8800' /etc/apache2/ports.conf
then
    echo "NameVirtualHost *:8800" >> /etc/apache2/ports.conf
fi

if ! grep -Fxq 'Listen 8800' /etc/apache2/ports.conf
then
    echo "Listen 8800" >> /etc/apache2/ports.conf
fi
