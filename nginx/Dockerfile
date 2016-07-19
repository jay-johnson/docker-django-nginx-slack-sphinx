FROM centos:7

# Define args and set a default value
ARG maintainer=jay.p.h.johnson@gmail.com
ARG imagename=django-nginx
ARG registry=docker.io

MAINTAINER $maintainer
LABEL Vendor="Anyone"
LABEL ImageType="nginx"
LABEL ImageName=$imagename
LABEL ImageOS=$basename
LABEL Version=$version

RUN yum -y install epel-release; yum clean all
RUN yum -y install python-pip; yum clean all; pip install --upgrade pip; yum -y install vim telnet curl mlocate logrotate rsyslog cron tar openssl openssl-dev net-tools

# Set default environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /root

# Allow triggerable events on the first time running
RUN touch /tmp/firsttimerunning

# Add Volumes and Set permissions
RUN mkdir -p -m 777 /root/shared \
    && mkdir -p -m 777 /root \
    && mkdir -p -m 777 /root/containerfiles \
    && echo "alias vi='vim'" >> ~/.bashrc \
    && echo "alias tl='tail -f /var/log/nginx/*'" >> ~/.bashrc \
    && echo "alias el='tail -f /var/log/nginx/error.log'" >> ~/.bashrc \
    && echo "alias al='tail -f /var/log/nginx/access.log'" >> ~/.bashrc

# Add the starters and installers:
ADD ./containerfiles/ /root/containerfiles

RUN chmod 777 /root/containerfiles/*.sh

# Add the nginx repository
RUN cp /root/containerfiles/nginx.repo /etc/yum.repos.d/nginx.repo

# Intalling the nginx 
RUN yum -y install nginx

# Adding the default file
RUN cp /root/containerfiles/index.html /usr/share/nginx/html

# Run/Compose ENV Variables:
ENV ENV_BASE_NGINX_CONFIG /root/containerfiles/base_nginx.conf
ENV ENV_DERIVED_NGINX_CONFIG /root/containerfiles/non_ssl.conf
ENV ENV_DEFAULT_ROOT_VOLUME /opt/web

# Port
EXPOSE 80 443

CMD ["/root/containerfiles/start-container.sh"]
