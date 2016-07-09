#!/bin/bash

source ./properties.sh .

if [ ! -d $ENV_DEFAULT_ROOT_VOLUME ]; then
    mkdir -p -m 777 $ENV_DEFAULT_ROOT_VOLUME
fi

if [ ! -d $ENV_DOC_SOURCE_DIR ]; then
    mkdir -p -m 777 $ENV_DOC_SOURCE_DIR
fi

if [ ! -d $ENV_DOC_OUTPUT_DIR ]; then
    mkdir -p -m 777 $ENV_DOC_OUTPUT_DIR
fi

if [ ! -d $ENV_STATIC_OUTPUT_DIR ]; then
    mkdir -p -m 777 $ENV_STATIC_OUTPUT_DIR
fi

if [ ! -d $ENV_MEDIA_DIR ]; then
    mkdir -p -m 777 $ENV_MEDIA_DIR
fi

echo "Starting new Docker image($registry/$maintainer/$imagename)"
docker run --name=$imagename \
            -e ENV_BASE_DOMAIN=$ENV_BASE_DOMAIN \
            -e ENV_GOOGLE_ANALYTICS_CODE=$ENV_GOOGLE_ANALYTICS_CODE \
            -e ENV_DJANGO_DEBUG_MODE=$ENV_DJANGO_DEBUG_MODE \
            -e ENV_SERVER_MODE=$ENV_SERVER_MODE \
            -e ENV_DEFAULT_PORT=$ENV_DEFAULT_PORT \
            -e ENV_BASE_HOMEDIR=$ENV_BASE_HOMEDIR \
            -e ENV_BASE_REPO_DIR=$ENV_BASE_REPO_DIR \
            -e ENV_BASE_DATA_DIR=$ENV_BASE_DATA_DIR \
            -v $ENV_DEFAULT_ROOT_VOLUME:$ENV_DEFAULT_ROOT_VOLUME \
            -v $ENV_DOC_SOURCE_DIR:$ENV_DOC_SOURCE_DIR \
            -v $ENV_DOC_OUTPUT_DIR:$ENV_DOC_OUTPUT_DIR \
            -v $ENV_STATIC_OUTPUT_DIR:$ENV_STATIC_OUTPUT_DIR \
            -v $ENV_MEDIA_DIR:$ENV_MEDIA_DIR \
            -p 82:80 \
            -p 444:443 \
            -d $maintainer/$imagename 

exit 0
