==================================
Docker + nginx for SSL and Non-SSL
==================================

This is a repository_ for hosting a configurable docker + nginx container running on CentOS 7. I use this container for hosting HTTP traffic and static files for the Django server.

.. image:: http://jaypjohnson.com/_images/image_nginx.png
   :align: center

Docker Hub Image: `jayjohnson/django-nginx`_

.. role:: bash(code)
      :language: bash

Overview
--------

I built this container so I could have an extensible nginx container that could utilize a mounted volume for static files and ssl certs. By default this container will start by installing the necessary configuration files and then start a backgrounded nginx process.

By default the nginx server assumes there is `Django server upstream`_ on a machine named ``webserver`` listening on port **85**.

.. _Django server upstream: https://github.com/jay-johnson/docker-django-nginx-slack-sphinx/blob/4d8b5360a514d03dce7f420643cee958c1ac9669/nginx/containerfiles/non_ssl.conf#L27-L29

Environment Variables
~~~~~~~~~~~~~~~~~~~~~

Here are the available environment variables that are used by the start_container.sh_ script as the container starts up. By using environment variables to drive one-time install/configuration behaviors this container can be used with `docker compose`_ for other technologies that I want to use with nginx. 

+-----------------------------------+---------------------------------------------+-------------------------------------------------------------+ 
| Variable Name                     | Purpose                                     | Default Value                                               | 
+===================================+=============================================+=============================================================+ 
| **ENV_DEFAULT_ROOT_VOLUME**       | Path to shared volume for static assets     | /opt/web                                                    | 
+-----------------------------------+---------------------------------------------+-------------------------------------------------------------+ 
| **ENV_BASE_NGINX_CONFIG**         | Provide a path to a `base_nginx.conf`_      | /root/containerfiles/base_nginx.conf                        | 
+-----------------------------------+---------------------------------------------+-------------------------------------------------------------+
| **ENV_DERIVED_NGINX_CONFIG**      | Provide a path to a `non_ssl.conf`_         | /root/containerfiles/non_ssl.conf                           | 
+-----------------------------------+---------------------------------------------+-------------------------------------------------------------+


Getting Started
---------------

By default this container exposes ports: ``80`` and ``443`` from the container to the host OS. 

Building
~~~~~~~~

To build the container you can run ``build.sh`` that automatically sources the properties.sh_ file: 

::

    $ ./build.sh 
    Building new Docker image(docker.io/jayjohnson/django-nginx)
    Sending build context to Docker daemon 37.38 kB
    Step 1 : FROM centos:7
     ---> 904d6c400333

    ...

    ---> 8bfb9d8ca828
    Successfully built 8bfb9d8ca828
    $

Here is the full the command:

::

    docker build --rm -t <your name>/django-nginx --build-arg registry=docker.io --build-arg maintainer=<your name> --build-arg imagename=django-nginx .


Start the Container
~~~~~~~~~~~~~~~~~~~

To start the container run:

::

    $ ./start.sh 
    Starting new Docker image(docker.io/jayjohnson/django-nginx)
    ad836abf4f30eb629d501b4c1cf5b9709001293dab4e3e6b886639bd00ab4d33
    $ 

Here is how the container starts inside the start.sh_:

::

    #!/bin/bash

    source ./properties.sh .

    echo "Starting new Docker image($registry/$maintainer/$imagename)"
    docker run --name=$imagename \
                -v $EXT_MOUNTED_VOLUME:$INT_MOUNTED_VOLUME \
                -e ENV_BASE_NGINX_CONFIG=$ENV_BASE_NGINX_CONFIG \
                -e ENV_DERIVED_NGINX_CONFIG=$ENV_DERIVED_NGINX_CONFIG \
                -e ENV_DEFAULT_ROOT_VOLUME=$ENV_DEFAULT_ROOT_VOLUME \
                -p 80:80 \
                -p 443:443 \
                -d $maintainer/$imagename 

    exit 0



Test the Container
~~~~~~~~~~~~~~~~~~

When testing the container without Django running you will likely see this output:

::

    $ wget http://localhost/home -t 1
    --2016-07-08 13:33:10--  http://localhost/home
    Resolving localhost (localhost)... 127.0.0.1
    Connecting to localhost (localhost)|127.0.0.1|:80... connected.
    HTTP request sent, awaiting response... Read error (Connection reset by peer) in headers.
    Giving up.

    $ curl -i -v http://localhost/home -t 1
    *   Trying 127.0.0.1...
    * Connected to localhost (127.0.0.1) port 80 (#0)
    > GET /home HTTP/1.1
    > User-Agent: curl/7.40.0
    > Host: localhost
    > Accept: */*
    > 
    * Empty reply from server
    * Connection #0 to host localhost left intact
    curl: (52) Empty reply from server


Stop the Container
~~~~~~~~~~~~~~~~~~

To stop the container run:

::

    $ ./stop.sh 
    Stopping Docker image(docker.io/jayjohnson/django-nginx)
    django-nginx
    $ 

Or run the command:

::
    
    $ docker stop django-nginx


Licenses
--------

This repository is licensed under the MIT License.

The nginx license: http://nginx.org/LICENSE


.. _docker compose: https://docs.docker.com/compose/
.. _repository: https://github.com/jay-johnson/docker-django-nginx-slack-sphinx/
.. _jayjohnson/django-nginx : https://hub.docker.com/r/jayjohnson/django-nginx/
.. _start.sh: https://github.com/jay-johnson/docker-django-nginx-slack-sphinx/blob/master/nginx/start.sh
.. _start_container.sh: https://github.com/jay-johnson/docker-django-nginx-slack-sphinx/blob/master/nginx/containerfiles/start-container.sh
.. _properties.sh: https://github.com/jay-johnson/docker-django-nginx-slack-sphinx/blob/master/nginx/properties.sh
.. _base_nginx.conf: https://github.com/jay-johnson/docker-django-nginx-slack-sphinx/blob/master/nginx/containerfiles/base_nginx.conf
.. _non_ssl.conf: https://github.com/jay-johnson/docker-django-nginx-slack-sphinx/blob/master/nginx/containerfiles/non_ssl.conf

