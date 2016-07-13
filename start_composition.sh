#!/bin/bash

filetouse="docker-compose.yml"

# To run the composition with the testing tags: 
#    export DEPLOY_ENV="TEST"
#
# Note: Make sure the containers are removed 
# when switching between tags like:
#    latest -> testing
#
#    $ docker rm webnginx webserver
#
if [ "$DEPLOY_ENV" != "" ]; then
    if [ "$DEPLOY_ENV" == "TEST" ]; then
        filetouse="testing-docker-compose.yml"
    fi
fi

echo "Starting Composition: $filetouse"
docker-compose -f $filetouse up -d
echo "Done"

exit 0
