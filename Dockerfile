FROM alpine:3.13.2

MAINTAINER Peter Szalatnay <theotherland@gmail.com>

ENV PXC_VERSION 8.0.21-12.1

RUN set -eux; \
    addgroup -S mysql; \
    adduser -D -S -h /var/lib/mysql -s /sbin/nologin -G mysql mysql; \
    apk add --update --no-cache \
        curl \
        bash \
        libpwquality \
        tzdata; \
    cd /tmp; \
    curl -fSL "https://github.com/Flowman/pxc-alpine/releases/download/$PXC_VERSION/percona-xtradb-cluster-client-8.0.21-r0.apk" -o "percona-xtradb-cluster-client-8.0.21-r0.apk"; \
    curl -fSL "https://github.com/Flowman/pxc-alpine/releases/download/$PXC_VERSION/percona-xtradb-cluster-common-8.0.21-r0.apk" -o "percona-xtradb-cluster-common-8.0.21-r0.apk"; \
    curl -fSL "https://github.com/Flowman/pxc-alpine/releases/download/$PXC_VERSION/percona-xtradb-cluster-8.0.21-r0.apk" -o "percona-xtradb-cluster-8.0.21-r0.apk"; \
    curl -fSL "https://github.com/Flowman/pxc-alpine/releases/download/$PXC_VERSION/percona-xtrabackup-8.0.22-r0.apk" -o "percona-xtrabackup-8.0.22-r0.apk"; \
    apk add --allow-untrusted --no-cache \
        percona-xtradb-cluster-client-8.0.21-r0.apk \
        percona-xtradb-cluster-common-8.0.21-r0.apk \
        percona-xtradb-cluster-8.0.21-r0.apk \
        percona-xtrabackup-8.0.22-r0.apk; \
    rm /tmp/percona*;

RUN rm -rf /etc/mysql/mysql.conf.d; \
    rm -f /etc/mysql/*.cnf*; \
    ln -s /etc/mysql/conf.d /etc/my.cnf.d; \
    rm -f /etc/percona-xtradb-cluster.conf.d/*.cnf; \
    echo '!include /etc/mysql/node.cnf' > /etc/my.cnf; \
    echo '!includedir /etc/my.cnf.d/' >> /etc/my.cnf; \
    echo '!includedir /etc/percona-xtradb-cluster.conf.d/' >> /etc/my.cnf;

COPY dockerdir /
RUN mkdir -p /etc/mysql/conf.d/ /var/log/mysql /var/lib/mysql /docker-entrypoint-initdb.d /etc/percona-xtradb-cluster.conf.d; \
    chown -R mysql:mysql /etc/mysql/ /var/log/mysql /var/lib/mysql /docker-entrypoint-initdb.d /etc/percona-xtradb-cluster.conf.d; \
    chmod -R g=u /etc/mysql/ /var/log/mysql /var/lib/mysql /docker-entrypoint-initdb.d /etc/percona-xtradb-cluster.conf.d

VOLUME ["/var/lib/mysql", "/run/mysqld"]

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

USER mysql

EXPOSE 3306 4567 4568 33060

CMD ["mysqld"]
