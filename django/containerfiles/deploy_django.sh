#!/bin/bash
# This deploy hook gets executed after dependencies are resolved and the
# build hook has been run but before the application has been started back
# up again.  This script gets executed directly, so it could be python, php,
# ruby, etc.

log="/tmp/migrate.log"

if [ ! -f ${ENV_BASE_DATA_DIR}/secrets.json ]; then
	echo "Generating ${ENV_BASE_DATA_DIR}/secrets.json"
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
