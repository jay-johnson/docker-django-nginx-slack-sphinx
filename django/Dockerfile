FROM centos:7

# Define args and set a default value
ARG maintainer=jay.p.h.johnson@gmail.com
ARG imagename=django
ARG registry=docker.io

MAINTAINER $maintainer
LABEL Vendor="Anyone"
LABEL ImageType="django"
LABEL ImageName=$imagename
LABEL ImageOS=$basename
LABEL Version=$version

# Update and install django
RUN yum -y update; yum -y install epel-release; yum clean all
RUN yum -y install python-pip; yum clean all; pip install --upgrade pip; yum -y install git sqlite vim wget mlocate cron rsyslog logrotate gcc telnet curl tar python-devel mariadb-devel postgresql-devel net-tools
RUN pip install --upgrade Django sphinx slackclient uuid sphinx_bootstrap_theme requests django-redis uwsgi MySQL-python psycopg2 pymongo SQLAlchemy alembic

# Set default environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /root

# Add Volumes and Set permissions
RUN mkdir -p -m 777 /root/shared \
    && mkdir -p -m 777 /root \
    && mkdir -p -m 777 /opt \
    && mkdir -p -m 777 /opt/containerfiles \
    && chmod 777 /opt \
    && chmod 777 /opt/containerfiles \
    && touch /tmp/firsttimerunning \
    && echo "alias vi='vim'" >> ~/.bashrc \
    && echo "alias pj='cd \$ENV_PROJ_DIR'" >> ~/.bashrc \
    && echo "alias html='cd \$ENV_PROJ_DIR/templates/'" >> ~/.bashrc \
    && echo "alias cs='cd /opt/containerfiles/ && ./run_collectstatic.sh'" >> ~/.bashrc \
    && echo "alias tl='tail -f /tmp/server.log'" >> ~/.bashrc

# Run/Compose ENV Variables:
ENV ENV_BASE_HOMEDIR /opt
ENV ENV_BASE_REPO_DIR /opt/containerfiles/django
ENV ENV_BASE_DATA_DIR /opt/containerfiles/django/data
ENV ENV_DEFAULT_ROOT_VOLUME /opt/web
ENV ENV_DOC_SOURCE_DIR /opt/web/django/blog/source
ENV ENV_DOC_OUTPUT_DIR /opt/web/django/templates
ENV ENV_STATIC_OUTPUT_DIR /opt/web/static
ENV ENV_MEDIA_DIR /opt/web/media
ENV ENV_BASE_DOMAIN jaypjohnson.com
ENV ENV_SLACK_BOTNAME bugbot
ENV ENV_SLACK_CHANNEL debugging
ENV ENV_SLACK_NOTIFY_USER jay
ENV ENV_SLACK_TOKEN xoxb-51351043345-Lzwmto5IMVb8UK36MghZYMEi
ENV ENV_SLACK_ENVNAME djangoapp
ENV ENV_SEND_EX_TO_SLACK True
ENV ENV_GOOGLE_ANALYTICS_CODE UA-79840762-99
ENV ENV_DJANGO_DEBUG_MODE True
ENV ENV_SERVER_MODE DEV
ENV ENV_DEFAULT_PORT 80
ENV ENV_PROJ_DIR /opt/containerfiles/django/wsgi/server/webapp

# Port
EXPOSE 80 443

# Add the starters and installers:
ADD ./containerfiles/ /opt/containerfiles

RUN chmod 777 /opt/containerfiles/*.sh

CMD ["/opt/containerfiles/start-container.sh"]
