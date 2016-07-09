#!/bin/bash

log="/tmp/collectstatic.log"

pushd ${ENV_BASE_REPO_DIR}/wsgi/server/ &> $log
echo "$(date +'%m-%d-%y %H:%M:%S') CollectingStatic" >> $log
python ./manage.py collectstatic --noinput &>> $log
echo "$(date +'%m-%d-%y %H:%M:%S') Done CollectingStatic" >> $log
popd &>> $log

exit 0 
