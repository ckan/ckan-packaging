#!/bin/bash

if [ ! -f /etc/ckan/default/ckan.ini ];
then
    /usr/lib/ckan/default/bin/ckan generate config /etc/ckan/default/ckan.ini
fi 

if [ -f /etc/nginx/sites-enabled/default ];
then
	rm -f /etc/nginx/sites-enabled/default
fi

if [ ! -f /etc/nginx/sites-enabled/ckan ];
then
	ln -s /etc/nginx/sites-available/ckan /etc/nginx/sites-enabled/ckan
fi

if [ ! -d /var/lib/ckan/default/uploads/storage/uploads/user ];
then
    mkdir -p /var/lib/ckan/default/storage/uploads/user
fi
chown -R www-data:www-data /var/lib/ckan/default

if [ ! -d /usr/lib/ckan/default/src/ckan/ckan/public/base/i18n ];
then
    mkdir -p /usr/lib/ckan/default/src/ckan/ckan/public/base/i18n
fi
chown -R www-data:www-data /usr/lib/ckan/default/src/ckan/ckan/public/base/i18n

if [ ! -d /var/log/ckan ];
then
    mkdir /var/log/ckan
fi
chown -R www-data:adm /var/log/ckan



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
