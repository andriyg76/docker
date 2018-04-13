FROM ubuntu:bionic

ENV LANG=en_US.UTF-8

RUN \
    apt update && \
	apt install -y gpg && \
    apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 && \
    echo "deb http://nginx.org/packages/mainline/ubuntu/ xenial nginx" >> /etc/apt/sources.list && \
    apt update && \
    apt upgrade -y && \
    apt install -y --allow-unauthenticated \
        nginx supervisor \
        locales \
        ca-certificates tzdata python2.7 netcat htop less curl libmysqlclient20 \
        libjpeg8 libpng16-16 libxslt1.1 \
        libmysqlclient-dev python2.7-dev python-pip libjpeg8-dev libpng-dev libxslt1-dev && \
    locale-gen ${LANG} && \
    pip install -U pillow django-redis-cache pytz lxml gu-django-filebrowser-no-grappelli gu-django-tinymce mysqlclient uwsgi && \
    apt autoremove -y && \
    apt autoclean -y && \
    rm -rf /tmp/* /var/lib/apt/lists/* /root/.cache && \
    true
