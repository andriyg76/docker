FROM mysql:5.7

RUN \
    set -ex; \
    yum install -y python2 htop ;\
    rm -rf /var/cache/yum ; \
    true

ADD sqldump/ /sqldump/
