#!/bin/bash

echo ""
echo "Starting Django in debug mode"

pushd ./django >> /dev/null

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

mkdir -p -m 777 /opt/containerfiles/django/wsgi

export ENV_SERVER_MODE="DEV"
export ENV_BASE_DOMAIN="localhost"
export ENV_BASE_DATA_DIR=/opt/containerfiles/django
export ENV_BASE_REPO_DIR=/opt/containerfiles/django

if [ ! -d /opt/containerfiles ]; then
    echo "Creating fake deployment directory: /opt/containerfiles"
    mkdir -p -m 777 /opt/containerfiles
fi

# Now start the local deployment tools in the same order as the docker django-slack-sphinx container
if [ ! -d /opt/containerfiles ]; then
    echo ""
    echo "Error: The Django debug server requires being able to use: /opt/containerfiles"
    echo "       Please confirm /opt exists and this script has permissions to modify it"
    echo "       sudo mkdir -p -m 777 /opt/containerfiles"
    echo ""
    exit 1
else
    echo ""
    echo "Destroying previous deployment"
    rm -rf /opt/containerfiles/*
    echo ""

    echo "Creating temp Sphinx static dir"
    mkdir -p -m 777 /opt/containerfiles/django/wsgi/server/webapp/docs/../../../_static
    echo ""

    echo "Installing new build"
    cp -r ./containerfiles/* /opt/containerfiles/
    echo ""

    echo "Deploying Django"
    pushd /opt/containerfiles/ >> /dev/null
    ./deploy-django.sh 
    popd >> /dev/null
    echo ""

    echo "Deploying Docs"
    pushd /opt/containerfiles/django/wsgi/server/webapp >> /dev/null
    ./deploy-docs.sh 
    popd >> /dev/null
    echo ""

    pushd /opt/containerfiles/django/wsgi/server >> /dev/null
    echo "Starting Django Server with home page: http://localhost:8000/home/"
    python manage.py runserver 0.0.0.0:8000
    popd >> /dev/null
    echo ""
fi

popd >> /dev/null

echo ""

exit 0
