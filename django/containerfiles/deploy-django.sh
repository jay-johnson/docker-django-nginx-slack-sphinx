#!/bin/bash

log="/tmp/docsdeploy.log"

echo "     - To debug the deploy-django.sh script run: tail -f $log"

if [ ! -f ${ENV_BASE_DATA_DIR}/secrets.json ]; then
	echo "Generating ${ENV_BASE_DATA_DIR}/secrets.json" &>> $log
	python ${ENV_BASE_REPO_DIR}/libs/secrets.py > ${ENV_BASE_DATA_DIR}/secrets.json 
fi

echo "Executing 'python ${ENV_BASE_REPO_DIR}/wsgi/server/manage.py migrate --noinput'" &>> $log
pushd ${ENV_BASE_REPO_DIR}/wsgi/server/ &>> $log
python ./manage.py syncdb --noinput &>> $log
python ./manage.py migrate --noinput &>> $log
popd &>> $log

pushd ${ENV_BASE_REPO_DIR}/wsgi/server/ &>> $log
python ./manage.py collectstatic --noinput &>> $log
popd &>> $log

pushd ${ENV_BASE_REPO_DIR}/wsgi/server/webapp/ &>> $log
chmod 777 ./deploy-docs.sh &>> $log
./deploy-docs.sh &>> $log
popd &>> $log

exit 0 
