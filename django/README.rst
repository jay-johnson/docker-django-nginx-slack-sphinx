================================
Docker + Django + Slack + Sphinx
================================

A docker container for running a `Django web application`_ that is integrated into Slack for posting exceptions and technical documentation using Sphinx bootstrap. This is the next iteration for building a website capable of hosting dynamic documentation and reusing a dockerized Django webserver. Static assets are written to a mounted volume for sharing with an nginx server.

.. image:: http://jaypjohnson.com/_images/image_django-python.png
   :align: center

Docker Hub Image: `jayjohnson/django-slack-sphinx`_

.. role:: bash(code)
      :language: bash

.. _django web application: https://github.com/django/django

Overview
--------

I built this composition for hosting a CentOS 7 Django 1.9 server that is easy to debug using a `Slack integration`_ because it `publishes exceptions`_ and automatically converts **rst** documentation into stylized html via the sphinx-bootstrap-theme_ with bootstrap_ and includes `multiple bootswatch themes`_. For more details on this workflow, please refer to my previous `Slack driven development post`_. 

.. _Slack integration: https://github.com/jay-johnson/docker-django-nginx-slack-sphinx/blob/fb7ce4725d806d8a7aeb2ae90b20ff3718858a35/docker-compose.yml#L39-L44
.. _publishes exceptions: https://github.com/jay-johnson/docker-django-nginx-slack-sphinx/blob/fb7ce4725d806d8a7aeb2ae90b20ff3718858a35/django/containerfiles/django/wsgi/server/webapp/api.py#L40-L48
.. _sphinx-bootstrap-theme: https://github.com/ryan-roemer/sphinx-bootstrap-theme
.. _bootstrap: http://getbootstrap.com/
.. _multiple bootswatch themes: https://github.com/ryan-roemer/sphinx-bootstrap-theme/blob/bfb28af310ad5082fae01dc1ff08dab6ab3fa410/demo/source/conf.py#L146-L150
.. _Slack driven development post: http://jaypjohnson.com/2016-06-15-slack-driven-development.html
.. _bootswatch website: http://bootswatch.com/
.. _bootswatch repository: https://github.com/thomaspark/bootswatch

Environment Variables
~~~~~~~~~~~~~~~~~~~~~

Here are the available environment variables that are used by the start_container.sh_ script as the container starts up. By using environment variables to drive one-time install/configuration behaviors this container can be used with `docker compose`_ for other technologies that I want to use with nginx. 

+-----------------------------------+-----------------------------------------------------+-------------------------------------------------------------+ 
| Variable Name                     | Purpose                                             | Default Value                                               | 
+===================================+=====================================================+=============================================================+ 
| **ENV_BASE_HOMEDIR**              | Base Home dir                                       | /opt                                                        |
+-----------------------------------+-----------------------------------------------------+-------------------------------------------------------------+ 
| **ENV_BASE_REPO_DIR**             | Base Repository dir                                 | /opt/containerfiles/django/                                 |
+-----------------------------------+-----------------------------------------------------+-------------------------------------------------------------+ 
| **ENV_BASE_DATA_DIR**             | Base Data dir for SQL files                         | /opt/containerfiles/django/data/                            |
+-----------------------------------+-----------------------------------------------------+-------------------------------------------------------------+ 
| **ENV_DEFAULT_ROOT_VOLUME**       | Mounted and Shared Volume for passing files         | /opt/web                                                    |
+-----------------------------------+-----------------------------------------------------+-------------------------------------------------------------+ 
| **ENV_STATIC_OUTPUT_DIR**         | Output files dir for static files (js, css, images) | /opt/web/static                                             |
+-----------------------------------+-----------------------------------------------------+-------------------------------------------------------------+ 
| **ENV_MEDIA_DIR**                 | Output and upload dir for media files               | /opt/web/media                                              |
+-----------------------------------+-----------------------------------------------------+-------------------------------------------------------------+ 
| **ENV_BASE_DOMAIN**               | Base URL domain FQDN for the site                   | jaypjohnson.com                                             |
+-----------------------------------+-----------------------------------------------------+-------------------------------------------------------------+ 
| **ENV_SLACK_BOTNAME**             | Name of the Slack bot that will notify users        | bugbot                                                      |
+-----------------------------------+-----------------------------------------------------+-------------------------------------------------------------+ 
| **ENV_SLACK_CHANNEL**             | Name of the Slack channel                           | debugging                                                   |
+-----------------------------------+-----------------------------------------------------+-------------------------------------------------------------+ 
| **ENV_SLACK_NOTIFY_USER**         | Name of the user to notify in the Slack channel     | jay                                                         |
+-----------------------------------+-----------------------------------------------------+-------------------------------------------------------------+ 
| **ENV_SLACK_TOKEN**               | Slack bot api token for posting messages            | xoxb-51351043345-Lzwmto5IMVb8UK36MghZYMEi                   |
+-----------------------------------+-----------------------------------------------------+-------------------------------------------------------------+ 
| **ENV_SLACK_ENVNAME**             | Name of the application environment                 | djangoapp                                                   |
+-----------------------------------+-----------------------------------------------------+-------------------------------------------------------------+ 
| **ENV_GOOGLE_ANALYTICS_CODE**     | Google Analytics Tracking Code                      | UA-79840762-99                                              |
+-----------------------------------+-----------------------------------------------------+-------------------------------------------------------------+ 
| **ENV_DJANGO_DEBUG_MODE**         | Debug mode for the Django webserver                 | True                                                        |
+-----------------------------------+-----------------------------------------------------+-------------------------------------------------------------+ 
| **ENV_SERVER_MODE**               | Django run mode (non-prod vs fcgi)                  | DEV                                                         |
+-----------------------------------+-----------------------------------------------------+-------------------------------------------------------------+ 
| **ENV_DEFAULT_PORT**              | Django port it will listen on for traffic           | 80                                                          |
+-----------------------------------+-----------------------------------------------------+-------------------------------------------------------------+ 
| **ENV_PROJ_DIR**                  | Django project dir                                  | /opt/containerfiles/django/wsgi/server/webapp/              |
+-----------------------------------+-----------------------------------------------------+-------------------------------------------------------------+ 
| **ENV_DOC_SOURCE_DIR**            | Blog Source dir (not used yet)                      | /opt/web/django/blog/source                                 |
+-----------------------------------+-----------------------------------------------------+-------------------------------------------------------------+ 
| **ENV_DOC_OUTPUT_DIR**            | Blog Template dir (not used yet)                    | /opt/web/django/templates                                   |
+-----------------------------------+-----------------------------------------------------+-------------------------------------------------------------+ 


Getting Started
---------------

Building
~~~~~~~~

To build the container you can run ``build.sh`` that automatically sources the properties.sh_ file: 

::

    $ ./build.sh 
    Building new Docker image(docker.io/jayjohnson/django-slack-sphinx)
    Sending build context to Docker daemon 37.38 kB
    Step 1 : FROM centos:7
     ---> 904d6c400333

    ...

    ---> 8bfb9d8ca828
    Successfully built 8bfb9d8ca828
    $

Here is the full the command:

    :code:`docker build --rm -t <your name>/django-slack-sphinx --build-arg registry=docker.io --build-arg maintainer=<your name> --build-arg imagename=django-slack-sphinx .`


Start the Container
~~~~~~~~~~~~~~~~~~~

To start the container run:

::

    $ ./start.sh 
    Starting new Docker image(docker.io/jayjohnson/django-slack-sphinx)
    ff274de3633bff5b7b5db81b027b7572900a38641ff32d5eb56b880914471558
    $


Looking into the start.sh_ you can see that there are quite a few defaults taken from the properties.sh_ file:

::

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

Test the Container
~~~~~~~~~~~~~~~~~~

The default start script uses port **82** for development and documentation purposes instead of port **80** or **85** that is used in the stack composition.

Browse to http://localhost:82/home/ or test the page works from the command line

::

    $ curl -s http://localhost:82/home/ | grep Welcome
                <h1>Welcome to a Docker + Django Demo Site</h1>
    $

Stop the Container
~~~~~~~~~~~~~~~~~~

To stop the container run:

::

    $ ./stop.sh 
    Stopping Docker image(docker.io/jayjohnson/django-slack-sphinx)
    django-slack-sphinx
    django-slack-sphinx
    $ 


Or run the command:

::
    
    $ docker stop django-slack-sphinx

Running Django without Docker or uWSGI
--------------------------------------

Here are the steps to run Django locally without docker and without uWSGI.

1.  Install these pips on the host

    ::
        
        $ sudo pip install sphinx slackclient uuid sphinx_bootstrap_theme requests django-redis MySQL-python psycopg2 pymongo SQLAlchemy alembic

2.  Create the deployment workspace

    ::

        $ mkdir -p -m 777 /opt/containerfiles

3.  Run the debug-django.sh_ deployment script (in the repository root directory)

    ::

        $ ./debug-django.sh 

        Starting Django in debug mode

        Destroying previous deployment

        Creating temp Sphinx static dir

        Installing new build

        Deploying Django
             - To debug the deploy-django.sh script run: tail -f /tmp/docsdeploy.log

        Deploying Docs
             - To debug the deploy-docs.sh script run: tail -f /tmp/deploy.log

        Starting Django Server with home page: http://localhost:8000/home/
        Performing system checks...

        System check identified no issues (0 silenced).
        July 10, 2016 - 02:51:48
        Django version 1.8.3, using settings 'webapp.settings'
        Starting development server at http://0.0.0.0:8000/
        Quit the server with CONTROL-C.

    .. _debug-django.sh: https://github.com/jay-johnson/docker-django-nginx-slack-sphinx/blob/master/debug-django.sh

4.  Confirm the Django website is available at: ``http://localhost:8000/home/``

Licenses
--------

This repository is licensed under the MIT License.

The Django license: https://github.com/django/django/blob/master/LICENSE

Sphinx Bootstrap Theme is licensed under the MIT license.

Bootstrap v2 is licensed under the Apache license 2.0.

Bootstrap v3.1.0+ is licensed under the MIT license.

Bootswatch license: https://github.com/thomaspark/bootswatch/blob/gh-pages/LICENSE

.. _docker compose: https://docs.docker.com/compose/
.. _jayjohnson/django-slack-sphinx: https://hub.docker.com/r/jayjohnson/django-slack-sphinx/
.. _start.sh: https://github.com/jay-johnson/docker-django-nginx-slack-sphinx/blob/master/django/start.sh
.. _start_container.sh: https://github.com/jay-johnson/docker-django-nginx-slack-sphinx/blob/master/django/containerfiles/start-container.sh
.. _properties.sh: https://github.com/jay-johnson/docker-django-nginx-slack-sphinx/blob/master/django/properties.sh

