FROM ubuntu:xenial

ENV LANG=en_US.UTF-8

RUN \
    apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 && \
    echo "deb http://nginx.org/packages/mainline/ubuntu/ xenial nginx" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --allow-unauthenticated \
        nginx supervisor \
        locales \
        ca-certificates tzdata python2.7 netcat htop less curl libmysqlclient20 \
        libjpeg8 libpng12-0 libxslt1.1 \
        libmysqlclient-dev python2.7-dev python-pip libjpeg8-dev libpng12-dev libxslt1-dev && \
    locale-gen ${LANG} && \
    pip install -U pillow django-redis-cache pytz lxml gu-django-filebrowser-no-grappelli gu-django-tinymce mysqlclient uwsgi && \
    apt-get autoremove -y && \
    apt-get autoclean -y && \
    rm -rf /tmp/* /var/lib/apt/lists/* /root/.cache && \
    true
