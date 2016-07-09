====================================================================
Docker Compose for running a Django + nginx + Slack + Sphinx website
====================================================================

This is a repository for deploying a Django + nginx stack using docker compose. 

.. figure:: http://jaypjohnson.com/_images/image_2016-07-10_docker-django-nginx-slack-sphinx.png

I built this to make running a Django + nginx website easier (and for decoupling my sites from only running on AWS EC2 AMIs). It uses `docker compose`_ to deploy two containers (django-nginx_ and django-slack-sphinx_) and shares a mounted host volume between the two containers. For now, this runs Django 1.9 in uWSGI_ mode and publishes errors directly to a configurable Slack channel for debugging. By default the nginx container is running in `non-ssl mode`_, but the container and repo include an ssl.conf_ file as a reference for extending as needed.

.. _STATIC_ROOT 404 issues: http://stackoverflow.com/questions/12809416/django-static-files-404
.. _docker compose: https://docs.docker.com/compose/
.. _django-nginx : https://hub.docker.com/r/jayjohnson/django-nginx/
.. _django-slack-sphinx: https://hub.docker.com/r/jayjohnson/django-slack-sphinx/
.. _uWSGI: https://uwsgi-docs.readthedocs.io/en/latest/
.. _non-ssl mode: https://github.com/jay-johnson/docker-django-nginx-slack-sphinx/blob/master/nginx/containerfiles/non_ssl.conf
.. _ssl.conf: https://github.com/jay-johnson/docker-django-nginx-slack-sphinx/blob/master/nginx/containerfiles/ssl.conf

Overview
--------

I built this composition for hosting a Django server that is easy to debug using a `Slack integration`_ because it `publishes exceptions`_ and automatically converts **rst** documentation into stylized html via the sphinx-bootstrap-theme_ with bootstrap_ and includes `multiple bootswatch themes`_. For more details on this workflow, please refer to my previous `Slack driven development post`_. 

The two containers mount a shared volume hosted at: ``/opt/web/`` and Django `deploys the static assets`_ to ``/opt/web/static`` for hosting using nginx. Before now, I had to bake EC2 AMIs to run Django and nginx together and this just felt tedious to update and maintain. I want to have the option to not run on AWS and docker is a great tool for helping in this effort. I drink the docker kool-aid...containers make it easier to build, ship and run complex technical components like lego blocks. I also included directories for rebuilding or extending each container as needed in the repository.

Lastly, there has been a part of me that wanted to stop battling Django `STATIC_ROOT 404 issues`_ once and for all.

.. _Slack integration: https://github.com/jay-johnson/docker-django-nginx-slack-sphinx/blob/44a56b864ae50cbcc77891c49cfa9bf57d2c4af9/docker-compose.yml#L39-L44
.. _publishes exceptions: https://github.com/jay-johnson/docker-django-nginx-slack-sphinx/blob/44a56b864ae50cbcc77891c49cfa9bf57d2c4af9/django/containerfiles/django/wsgi/server/webapp/api.py#L40-L48
.. _sphinx-bootstrap-theme: https://github.com/ryan-roemer/sphinx-bootstrap-theme
.. _bootstrap: http://getbootstrap.com/
.. _multiple bootswatch themes: https://github.com/ryan-roemer/sphinx-bootstrap-theme/blob/bfb28af310ad5082fae01dc1ff08dab6ab3fa410/demo/source/conf.py#L146-L150
.. _Slack driven development post: http://jaypjohnson.com/2016-06-15-slack-driven-development.html
.. _deploys the static assets: https://github.com/jay-johnson/docker-django-nginx-slack-sphinx/blob/44a56b864ae50cbcc77891c49cfa9bf57d2c4af9/django/containerfiles/django/wsgi/server/webapp/settings.py#L131-L135
.. _bootswatch website: http://bootswatch.com/
.. _bootswatch repository: https://github.com/thomaspark/bootswatch

Google Integration
------------------

The Django server is ready-to-go with `Google Analytics`_ + `Google Search Console`_. 

.. _Google Analytics: https://analytics.google.com/
.. _Google Search Console: https://www.google.com/webmasters/tools/

Integrating with Google Analytics
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#.  Set your `Google Analytics Tracking Code`_ to the ENV_GOOGLE_ANALYTICS_CODE_ environment variable before starting the composition

.. _Google Analytics Tracking Code: https://support.google.com/analytics/answer/1008080?hl=en

Integrating with Google Search Console
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1.  Automatic **sitemap.xml** creation

    On startup the Django container will `automatically build`_ a ``sitemap.xml`` from any files ending with a ``.rst`` extension in the repository's `docs directory`_ and any `routes in the urls.py file`_. Once the routes are processed the final sitemap.xml file is written and stored `in the webapp directory`_. This is handy when you want to integrate your site into the `Google Search Console`_ and it should look similar to: 

    http://jaypjohnson.com/sitemap.xml

.. _automatically build: https://github.com/jay-johnson/docker-django-nginx-slack-sphinx/blob/44a56b864ae50cbcc77891c49cfa9bf57d2c4af9/django/containerfiles/django/wsgi/server/webapp/deploy-docs.sh#L102-L130
.. _docs directory: https://github.com/jay-johnson/docker-django-nginx-slack-sphinx/blob/44a56b864ae50cbcc77891c49cfa9bf57d2c4af9/django/containerfiles/django/wsgi/server/webapp/deploy-docs.sh#L108-L115
.. _routes in the urls.py file: https://github.com/jay-johnson/docker-django-nginx-slack-sphinx/blob/44a56b864ae50cbcc77891c49cfa9bf57d2c4af9/django/containerfiles/django/wsgi/server/webapp/deploy-docs.sh#L117-L124
.. _in the webapp directory: https://github.com/jay-johnson/docker-django-nginx-slack-sphinx/tree/master/django/containerfiles/django/wsgi/server/webapp
.. _ENV_GOOGLE_ANALYTICS_CODE: https://github.com/jay-johnson/docker-django-nginx-slack-sphinx/blob/44a56b864ae50cbcc77891c49cfa9bf57d2c4af9/docker-compose.yml#L45

2.  Automatic **robots.txt** creation

    Like the `sitemap.xml`_, on startup the Django container will host a ``robots.txt`` file at the site's base FQDN like: 

    http://jaypjohnson.com/robots.txt

    For this initial release, the `robots.txt file`_ is just a flat, static file you can change anytime.

.. _sitemap.xml: https://github.com/jay-johnson/docker-django-nginx-slack-sphinx/blob/44a56b864ae50cbcc77891c49cfa9bf57d2c4af9/django/containerfiles/django/wsgi/server/webapp/api.py#L165-L167
.. _robots.txt file: https://github.com/jay-johnson/docker-django-nginx-slack-sphinx/blob/44a56b864ae50cbcc77891c49cfa9bf57d2c4af9/django/containerfiles/django/wsgi/server/webapp/deploy-docs.sh#L132-L136

SEO Meta Data
-------------

SEO meta data is helpful when you share a link to your site over social media like Twitter, Facebook, Linkedin, and on Slack because they will automatically retrieve this meta data and embed the values into the post.

1.  SEO meta data in the **rst** files

    Each `rst file can deploy SEO meta data`_ in a hidden comments section

.. note:: Please make sure the **rst** meta data uses the existing tags prefixed with ``SEO_META_`` as it is `parsed and injected during the deployment`_ of the container.

.. _rst file can deploy SEO meta data: https://raw.githubusercontent.com/jay-johnson/docker-django-nginx-slack-sphinx/master/django/containerfiles/django/wsgi/server/webapp/docs/2016-07-10-sample-post.rst
.. _parsed and injected during the deployment: https://github.com/jay-johnson/docker-django-nginx-slack-sphinx/blob/44a56b864ae50cbcc77891c49cfa9bf57d2c4af9/django/containerfiles/django/wsgi/server/webapp/deploy-docs.sh#L48-L99

2.  SEO meta data in the **html** files

    Each `html template file can deploy SEO meta data`_ by storing it in a `centralized JSON file`_ that is referenced by the URL. On startup Django `parses this JSON file`_ and then whenever the page's URL is requested the `meta data is retrieved and passed using the template context`_ for building the html template. Please refer to the `Django Template documentation`_ for more information on how these internals work.
    
.. _html template file can deploy SEO meta data: https://github.com/jay-johnson/docker-django-nginx-slack-sphinx/blob/44a56b864ae50cbcc77891c49cfa9bf57d2c4af9/django/containerfiles/django/wsgi/server/webapp/templates/index.html#L11-L37
.. _centralized JSON file: https://github.com/jay-johnson/docker-django-nginx-slack-sphinx/blob/master/django/containerfiles/django/wsgi/server/webapp/meta_data_seo.json#L3-L13
.. _parses this JSON file: https://github.com/jay-johnson/docker-django-nginx-slack-sphinx/blob/44a56b864ae50cbcc77891c49cfa9bf57d2c4af9/django/containerfiles/django/wsgi/server/webapp/settings.py#L199-L201
.. _meta data is retrieved and passed using the template context: https://github.com/jay-johnson/docker-django-nginx-slack-sphinx/blob/44a56b864ae50cbcc77891c49cfa9bf57d2c4af9/django/containerfiles/django/wsgi/server/webapp/api.py#L94-L98
.. _Django Template documentation: https://docs.djangoproject.com/en/1.9/ref/templates/api/

Slack Integration
-----------------

This composition assumes you have a registered Slack bot that has been invited to the appropriate channel for posting messages. Please refer to the previous `Slack driven development post`_ for more details. With the Slack pieces set up, you can change the docker compose `Slack env variables`_ and then start the composition.

To disable the Slack integration just flip the **ENV_SEND_EX_TO_SLACK** environment variable to `anything that is not True`_

To test the Slack integration is working you can browse to the site: 

http://localhost/slackerror/

If it is working you should see the bot post a simple debugging message.

.. _Slack env variables: https://github.com/jay-johnson/docker-django-nginx-slack-sphinx/blob/44a56b864ae50cbcc77891c49cfa9bf57d2c4af9/docker-compose.yml#L39-L44
.. _anything that is not True: https://github.com/jay-johnson/docker-django-nginx-slack-sphinx/blob/44a56b864ae50cbcc77891c49cfa9bf57d2c4af9/django/containerfiles/django/wsgi/server/webapp/settings.py#L143

Compose Environment Variables
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can use the following environment variables inside the docker-compose.yml_ file to configure the startup and running behaviors for each container:

+-----------------------------------+-----------+-----------------------------------------------------+-------------------------------------------------------------+
| Variable Name                     | Container | Purpose                                             | Default Value                                               |
+===================================+===========+=====================================================+=============================================================+
| **ENV_BASE_HOMEDIR**              | Django    | Base Home dir                                       | /opt                                                        |
+-----------------------------------+-----------+-----------------------------------------------------+-------------------------------------------------------------+
| **ENV_BASE_REPO_DIR**             | Django    | Base Repository dir                                 | /opt/containerfiles/django/                                 |
+-----------------------------------+-----------+-----------------------------------------------------+-------------------------------------------------------------+
| **ENV_BASE_DATA_DIR**             | Django    | Base Data dir for SQL files                         | /opt/containerfiles/django/data/                            |
+-----------------------------------+-----------+-----------------------------------------------------+-------------------------------------------------------------+
| **ENV_BASE_DOMAIN**               | Django    | Base URL domain FQDN for the site                   | jaypjohnson.com                                             |
+-----------------------------------+-----------+-----------------------------------------------------+-------------------------------------------------------------+
| **ENV_STATIC_OUTPUT_DIR**         | Django    | Output files dir for static files (js, css, images) | /opt/web/static                                             |
+-----------------------------------+-----------+-----------------------------------------------------+-------------------------------------------------------------+
| **ENV_MEDIA_DIR**                 | Django    | Output and upload dir for media files               | /opt/web/media                                              |
+-----------------------------------+-----------+-----------------------------------------------------+-------------------------------------------------------------+
| **ENV_SLACK_BOTNAME**             | Django    | Name of the Slack bot that will notify users        | bugbot                                                      |
+-----------------------------------+-----------+-----------------------------------------------------+-------------------------------------------------------------+
| **ENV_SLACK_CHANNEL**             | Django    | Name of the Slack channel                           | debugging                                                   |
+-----------------------------------+-----------+-----------------------------------------------------+-------------------------------------------------------------+
| **ENV_SLACK_NOTIFY_USER**         | Django    | Name of the user to notify in the Slack channel     | jay                                                         |
+-----------------------------------+-----------+-----------------------------------------------------+-------------------------------------------------------------+
| **ENV_SLACK_TOKEN**               | Django    | Slack bot api token for posting messages            | xoxb-51351043345-Lzwmto5IMVb8UK36MghZYMEi                   |
+-----------------------------------+-----------+-----------------------------------------------------+-------------------------------------------------------------+
| **ENV_SLACK_ENVNAME**             | Django    | Name of the application environment                 | djangoapp                                                   |
+-----------------------------------+-----------+-----------------------------------------------------+-------------------------------------------------------------+
| **ENV_GOOGLE_ANALYTICS_CODE**     | Django    | Google Analytics Tracking Code                      | UA-79840762-99                                              |
+-----------------------------------+-----------+-----------------------------------------------------+-------------------------------------------------------------+
| **ENV_DJANGO_DEBUG_MODE**         | Django    | Debug mode for the Django webserver                 | True                                                        |
+-----------------------------------+-----------+-----------------------------------------------------+-------------------------------------------------------------+
| **ENV_SERVER_MODE**               | Django    | Django run mode (non-prod vs uWSGI)                 | PROD                                                        |
+-----------------------------------+-----------+-----------------------------------------------------+-------------------------------------------------------------+
| **ENV_DEFAULT_PORT**              | Django    | Django port it will listen on for traffic           | 85                                                          |
+-----------------------------------+-----------+-----------------------------------------------------+-------------------------------------------------------------+
| **ENV_PROJ_DIR**                  | Django    | Django project dir                                  | /opt/containerfiles/django/wsgi/server/webapp/              |
+-----------------------------------+-----------+-----------------------------------------------------+-------------------------------------------------------------+
| **ENV_DOC_SOURCE_DIR**            | Django    | Blog Source dir (not used yet)                      | /opt/web/django/blog/source                                 |
+-----------------------------------+-----------+-----------------------------------------------------+-------------------------------------------------------------+
| **ENV_DOC_OUTPUT_DIR**            | Django    | Blog Template dir (not used yet)                    | /opt/web/django/templates                                   |
+-----------------------------------+-----------+-----------------------------------------------------+-------------------------------------------------------------+
| **ENV_BASE_NGINX_CONFIG**         | nginx     | Provide a path to a `base_nginx.conf`_              | /root/containerfiles/base_nginx.conf                        | 
+-----------------------------------+-----------+-----------------------------------------------------+-------------------------------------------------------------+
| **ENV_DERIVED_NGINX_CONFIG**      | nginx     | Provide a path to a `non_ssl.conf`_                 | /root/containerfiles/non_ssl.conf                           | 
+-----------------------------------+-----------+-----------------------------------------------------+-------------------------------------------------------------+
| **ENV_DEFAULT_ROOT_VOLUME**       | Both      | Mounted a hosted Volume for sharing files           | /opt/web                                                    |
+-----------------------------------+-----------+-----------------------------------------------------+-------------------------------------------------------------+

.. warning:: Please make sure the **django-nginx** and **django-slack-sphinx** containers use the **same base** ``ENV_DEFAULT_ROOT_VOLUME`` directory.

.. _docker-compose.yml: https://github.com/jay-johnson/docker-django-nginx-slack-sphinx/blob/master/docker-compose.yml
.. _base_nginx.conf: https://github.com/jay-johnson/docker-django-nginx-slack-sphinx/blob/master/nginx/containerfiles/base_nginx.conf
.. _non_ssl.conf: https://github.com/jay-johnson/docker-django-nginx-slack-sphinx/blob/master/nginx/containerfiles/non_ssl.conf

Docker Compose File
-------------------

This composition is using a version 2 `docker-compose.yml`_. It is setup to only expose ports **80** and **443** for nginx. It also specifies a `default bridge network`_ for allowing nginx to route http traffic to the Django webserver using `uWSGI options`_ and a shared volume ``/opt/web/static`` for deploying static assets (js, css, images) for nginx hosting.

.. _docker compose file: https://github.com/jay-johnson/docker-django-nginx-slack-sphinx/blob/master/docker-compose.yml
.. _default bridge network: https://docs.docker.com/engine/userguide/networking/default_network/
.. _uWSGI options: https://github.com/jay-johnson/docker-django-nginx-slack-sphinx/blob/44a56b864ae50cbcc77891c49cfa9bf57d2c4af9/nginx/containerfiles/non_ssl.conf#L45-L55

::

    version: '2'

    services:

      webnginx:
        image: jayjohnson/django-nginx
        container_name: "webnginx"
        hostname: "webnginx"
        environment:
          - ENV_BASE_NGINX_CONFIG=/root/containerfiles/base_nginx.conf
          - ENV_DERIVED_NGINX_CONFIG=/root/containerfiles/non_ssl.conf
          - ENV_DEFAULT_ROOT_VOLUME=/opt/web
        ports:
          - "80:80"
          - "443:443"
        volumes:
          - /opt/web:/opt/web
        networks:
          - webstack

      webserver:
        image: jayjohnson/django-slack-sphinx
        container_name: "webserver"
        hostname: "webserver"
        environment:
          - ENV_BASE_HOMEDIR=/opt
          - ENV_BASE_REPO_DIR=/opt/containerfiles/django
          - ENV_BASE_DATA_DIR=/opt/containerfiles/django/data
          - ENV_DEFAULT_ROOT_VOLUME=/opt/web
          - ENV_DOC_SOURCE_DIR=/opt/web/django/blog/source
          - ENV_DOC_OUTPUT_DIR=/opt/web/django/templates
          - ENV_STATIC_OUTPUT_DIR=/opt/web/static
          - ENV_MEDIA_DIR=/opt/web/media
          - ENV_DJANGO_DEBUG_MODE=True
          - ENV_SERVER_MODE=PROD
          - ENV_DEFAULT_PORT=85
          - ENV_PROJ_DIR=/opt/containerfiles/django/wsgi/server/webapp
          - ENV_BASE_DOMAIN=jaypjohnson.com
          - ENV_SLACK_BOTNAME=bugbot
          - ENV_SLACK_CHANNEL=debugging
          - ENV_SLACK_NOTIFY_USER=jay
          - ENV_SLACK_TOKEN=xoxb-51351043345-Lzwmto5IMVb8UK36MghZYMEi
          - ENV_SLACK_ENVNAME=djangoapp
          - ENV_SEND_EX_TO_SLACK=True
          - ENV_GOOGLE_ANALYTICS_CODE=UA-79840762-99
        volumes:
          - /opt/web:/opt/web
        networks:
          - webstack

    networks:
      webstack:
        driver: bridge


Creating a New Technical Document 
---------------------------------

I built this to host dynamic technical content that automatically converts **rst** files into stylized html using Sphinx_ and sphinx-bootstrap-theme_ discussed in the previous `how to host a technical blog`_ post. Just add a new **rst** file to the `rst document`_ directory and restart the Django webserver (or the composition) to see the new posting on the http://localhost/docs/docs.html page.

.. _Sphinx: http://www.sphinx-doc.org/en/stable/
.. _how to host a technical blog: http://jaypjohnson.com/2016-06-25-host-a-technical-blog-with-docker.html
.. _rst document: https://github.com/jay-johnson/docker-django-nginx-slack-sphinx/tree/master/django/containerfiles/django/wsgi/server/webapp/docs

Tuning Django uWSGI
-------------------

If the composition is setup to run in **PROD** mode the Django container will run using ``uWSGI``. It uses the django-uwsgi.ini_ configuration file and specifies the experimental `thunder lock`_ performance option. The default configuration file tells uWSGI to run with 2 processes and 4 threads per process. 

::

    $ cat django-uwsgi.ini 
    [uwsgi]
    socket = 0.0.0.0:85
    chdir = /opt/containerfiles/django/wsgi/server
    wsgi-file = webapp/wsgi.py
    processes = 2
    threads = 4

.. note:: This may not be an ideal configuration for all cases, but it is easy enough to change and rebuild the Django docker container.

.. warning:: The ``--thunder-lock`` parameter is an `experimental feature`_. To disable it just change the compose file's `ENV_SERVER_MODE`_ value from **PROD** to **STANDARD** (anything not DEV or PROD).

.. _django-uwsgi.ini: https://github.com/jay-johnson/docker-django-nginx-slack-sphinx/blob/master/django/containerfiles/django/wsgi/server/django-uwsgi.ini
.. _thunder lock: https://github.com/jay-johnson/docker-django-nginx-slack-sphinx/blob/44a56b864ae50cbcc77891c49cfa9bf57d2c4af9/django/containerfiles/start-container.sh#L25-L34
.. _experimental feature: http://uwsgi-docs.readthedocs.io/en/latest/articles/SerializingAccept.html#uwsgi-developers-are-fu-ing-cowards
.. _ENV_SERVER_MODE: https://github.com/jay-johnson/docker-django-nginx-slack-sphinx/blob/44a56b864ae50cbcc77891c49cfa9bf57d2c4af9/docker-compose.yml#L35

Building Containers
-------------------

To build both containers just run:

::

    $ ./build-containers.sh
   

Install and Setup
-----------------

#.  Create the ``/opt/web`` directory

    ::

        $ mkdir -p /opt/web && chmod 777 /opt/web

#.  Start the composition

    ::

        $ ./start_composition.sh
        Starting Composition: docker-compose.yml
        Starting webserver
        Starting webnginx
        Done
        $

#.  Test the ``http://localhost/home/`` page works from a broser

    .. figure:: http://jaypjohnson.com/_images/image_2016-07-10_home-page-demo.png

#.  Test the ``http://localhost/home/`` page works from the command line

    ::

        $ curl -s http://localhost/home/ | grep Welcome
                    <h1>Welcome to a Docker + Django Demo Site</h1>
        $


Stopping the site
~~~~~~~~~~~~~~~~~

To stop the site run:

::

    $ ./stop_composition.sh 
    Stopping the Composition
    Stopping webnginx ... done
    Stopping webserver ... done
    Done
    $

Cleanup the site containers
~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you want to stop and cleanup the site and docker containers run these commands:

#.  Check the site containers are running

    ::

        $ docker ps
        CONTAINER ID        IMAGE                            COMMAND                  CREATED             STATUS                   PORTS                                      NAMES
        fa93f6b30a34        jayjohnson/django-nginx          "/root/containerfiles"   9 minutes ago       Up 14 seconds            0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp   webnginx
        0adba5cf4601        jayjohnson/django-slack-sphinx   "/opt/containerfiles/"   58 minutes ago      Up 14 seconds            80/tcp, 443/tcp                            webserver
        $

#.  Stop the composition

    ::

        $ ./stop_composition.sh 
        Stopping the Composition
        Stopping webnginx ... done
        Stopping webserver ... done
        Done
        $

#.  Remove the containers

    ::

        $ docker rm webnginx webserver
        webnginx
        webserver
        $

#.  Remove the container images

    ::

        $ docker rmi jayjohnson/django-nginx jayjohnson/django-slack-sphinx

#.  Remove the blog directory

    :: 

        $ rm -rf /opt/blog/repo

Licenses
--------

This repository is licensed under the MIT license.

The Django license: https://github.com/django/django/blob/master/LICENSE

The nginx license: http://nginx.org/LICENSE

Sphinx Bootstrap Theme is licensed under the MIT license.

Bootstrap v2 is licensed under the Apache license 2.0.

Bootstrap v3.1.0+ is licensed under the MIT license.

Bootswatch license: https://github.com/thomaspark/bootswatch/blob/gh-pages/LICENSE

