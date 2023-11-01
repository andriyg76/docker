FROM mysql:8

RUN \
    set -ex; \
    microdnf install -y python2 ;\
    rm -rf /var/cache/yum ; \
    true

ADD sqldump/ /sqldump/
