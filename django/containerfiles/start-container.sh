#!/bin/bash

log="/tmp/start.log"
serverlog="/tmp/server.log"

echo "$(date +'%m-%d-%y %H:%M:%S') Starting Container" > $log
date >> $log
echo "$(date +'%m-%d-%y %H:%M:%S') Environment Variables" >> $log
env | sort >> $log
echo "$(date +'%m-%d-%y %H:%M:%S') " >> $log

echo "$(date +'%m-%d-%y %H:%M:%S') Deploying Django" >> $log
chmod 777 /opt/containerfiles/deploy_django.sh
/opt/containerfiles/deploy_django.sh &>> $log
echo "$(date +'%m-%d-%y %H:%M:%S') Done Deploying Django" >> $log

echo "$(date +'%m-%d-%y %H:%M:%S') Starting($ENV_SERVER_MODE)" >> $log
pushd ${ENV_BASE_REPO_DIR}/wsgi/server/ >> $log
if [ "$ENV_SERVER_MODE" == "DEV" ]; then
    python ./manage.py runserver 0.0.0.0:$ENV_DEFAULT_PORT &> $serverlog
else

    # For this version the uWSGI modes host on port 85 and it is not configurable (nginx configs need to be patched)

    if [ "$ENV_SERVER_MODE" == "PROD" ]; then
        # http://uwsgi-docs.readthedocs.io/en/latest/articles/SerializingAccept.html#uwsgi-docs-sucks-thunder-lock
        # http://uwsgi-docs.readthedocs.io/en/latest/articles/SerializingAccept.html#uwsgi-developers-are-fu-ing-cowards
        # Linux pthread robust mutexes are solid, we are "pretty" sure about that, so you should be able to 
        # enable --thunder-lock on modern Linux systems with a 99.999999% success rates, 
        # but we prefer (for now) users consciously enable it
        echo "$(date +'%m-%d-%y %H:%M:%S') Booting up with --thunder-lock" >> $log
        pwd > $serverlog
        ls >> $serverlog
        uwsgi ./django-uwsgi.ini --thunder-lock &>> $serverlog
    else
        echo "$(date +'%m-%d-%y %H:%M:%S') Booting up" >> $log
        pwd > $serverlog
        ls >> $serverlog
        uwsgi ./django-uwsgi.ini &>> $serverlog
    fi
fi
popd >> $log

echo "$(date +'%m-%d-%y %H:%M:%S') Done Starting" >> $log

echo "$(date +'%m-%d-%y %H:%M:%S') Preventing the container from exiting" >> $log
tail -f /tmp/start.log
echo "$(date +'%m-%d-%y %H:%M:%S') Done preventing the container from exiting" >> $log

exit 0
