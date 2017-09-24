FROM ubuntu:xenial

RUN \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --allow-unauthenticated \
        ca-certificates tzdata python2.7 netcat htop less curl libmysqlclient20 \
        libjpeg8 libpng12-0 libxslt1.1 \
        libmysqlclient-dev python2.7-dev python-pip libjpeg8-dev libpng12-dev libxslt1-dev && \
    pip install -U pillow django-redis-cache pytz lxml gu-django-filebrowser-no-grappelli gu-django-tinymce mysqlclient uwsgi && \
    apt-get autoremove -y && \
    apt-get autoclean -y && \
    rm -rf /tmp/* /var/lib/apt/lists/* /root/.cache && \
    true
