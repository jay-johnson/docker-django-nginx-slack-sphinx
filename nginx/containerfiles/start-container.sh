#!/bin/bash

log="/tmp/start.log"

echo "$(date +'%m-%d-%y %H:%M:%S') Starting Container" > $log
date >> $log
echo "$(date +'%m-%d-%y %H:%M:%S') Environment Variables" >> $log
env | sort >> $log
echo "$(date +'%m-%d-%y %H:%M:%S') " >> $log

echo "$(date +'%m-%d-%y %H:%M:%S') Starting" >> $log

basenginxconf="/root/containerfiles/base_nginx.conf"
derivednginxconf="/root/containerfiles/non_ssl.conf"
defaultrootlocation="/usr/share/nginx/html"

# nginx.conf

echo "$(date +'%m-%d-%y %H:%M:%S') Checking for nginx.conf BASE ENV($ENV_BASE_NGINX_CONFIG)" >> $log
if [ -e "$ENV_BASE_NGINX_CONFIG" ]; then
    echo "$(date +'%m-%d-%y %H:%M:%S') -- Found nginx.conf BASE ENV($ENV_BASE_NGINX_CONFIG)" >> $log
    basenginxconf="$ENV_BASE_NGINX_CONFIG"
else
    echo "$(date +'%m-%d-%y %H:%M:%S') Using Default nginx BASE ENV($basenginxconf)" >> $log
fi

# derived nginx.conf

echo "$(date +'%m-%d-%y %H:%M:%S') Checking for nginx.conf DERIVED ENV($ENV_DERIVED_NGINX_CONFIG)" >> $log
if [ -e "$ENV_DERIVED_NGINX_CONFIG" ]; then
    echo "$(date +'%m-%d-%y %H:%M:%S') -- Found Derived nginx configuration DERIVED ENV($ENV_DERIVED_NGINX_CONFIG)" >> $log
    derivednginxconf="$ENV_DERIVED_NGINX_CONFIG"
else
    echo "$(date +'%m-%d-%y %H:%M:%S') Using Default nginx DERIVED ENV($derivednginxconf)" >> $log
fi

# container-mounted volume for static assets

defrootvolume="/usr/share/nginx/html"
echo "$(date +'%m-%d-%y %H:%M:%S') Checking for Default Root Volume ENV($ENV_DEFAULT_ROOT_VOLUME)" >> $log
if [ -d "$ENV_DEFAULT_ROOT_VOLUME" ]; then
    echo "$(date +'%m-%d-%y %H:%M:%S') -- Found Default Root Volume ENV($ENV_DEFAULT_ROOT_VOLUME)" >> $log
    defrootvolume="$ENV_DEFAULT_ROOT_VOLUME"
else

    echo "$(date +'%m-%d-%y %H:%M:%S') Letting the composition start" >> $log
    cur_count=0
    total_counts=10
    while [ $cur_count -lt $total_counts ];
    do
        if [ -d "$ENV_DEFAULT_ROOT_VOLUME" ]; then
            echo "$(date +'%m-%d-%y %H:%M:%S') -- Found Default Root Volume ENV($ENV_DEFAULT_ROOT_VOLUME) Retry($cur_count)" >> $log
            cur_count=$total_counts
            defrootvolume="$ENV_DEFAULT_ROOT_VOLUME"
        else
            let cur_count=cur_count+1
            echo "$(date +'%m-%d-%y %H:%M:%S') Waiting on Retry($cur_count)" >> $log
            sleep 1
        fi
        popd
    done

    echo "$(date +'%m-%d-%y %H:%M:%S') Using Root Volume ENV($defrootvolume)" >> $log
fi

# Install files

cp $basenginxconf /etc/nginx/nginx.conf
cp $derivednginxconf /etc/nginx/conf.d/default.conf

chmod 666 /etc/nginx/nginx.conf
chmod 666 /etc/nginx/conf.d/default.conf

# Configure files using ENV

echo "$(date +'%m-%d-%y %H:%M:%S') Configuring Root Volume($defrootvolume) File(/etc/nginx/conf.d/default.conf)" >> $log
sed -i -e "s|CHANGE_TO_DEFAULT_ROOT_VOLUME|$defrootvolume|g" /etc/nginx/conf.d/default.conf

echo "$(date +'%m-%d-%y %H:%M:%S') Starting nginx" >> $log
sleep 3
nohup nginx &  &>> $log
echo "$(date +'%m-%d-%y %H:%M:%S') Done Starting" >> $log

echo "$(date +'%m-%d-%y %H:%M:%S') Preventing the container from exiting" >> $log
tail -f /tmp/start.log
echo "$(date +'%m-%d-%y %H:%M:%S') Done preventing the container from exiting" >> $log

exit 0
