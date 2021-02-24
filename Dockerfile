FROM alpine:3.13.2

LABEL maintainer="Peter Szalatnay <theotherland@gmail.com>"

ENV PXC_VERSION 8.0.21
ENV PKG_RELEASE 12.1
ENV XTRABACKUP_VERSION 8.0.22

RUN set -eux; \
    addgroup -S mysql; \
    adduser -D -S -h /var/lib/mysql -s /sbin/nologin -G mysql mysql; \
    apk add --update --no-cache \
        curl \
        bash \
        libpwquality \
        tzdata; \
    cd /tmp; \
    curl -fSL "https://github.com/Flowman/pxc-alpine/releases/download/${PXC_VERSION}-${PKG_RELEASE}/percona-xtradb-cluster-client-${PXC_VERSION}-r0.apk" -o "percona-xtradb-cluster-client-${PXC_VERSION}-r0.apk"; \
    curl -fSL "https://github.com/Flowman/pxc-alpine/releases/download/${PXC_VERSION}-${PKG_RELEASE}/percona-xtradb-cluster-common-${PXC_VERSION}-r0.apk" -o "percona-xtradb-cluster-common-${PXC_VERSION}-r0.apk"; \
    curl -fSL "https://github.com/Flowman/pxc-alpine/releases/download/${PXC_VERSION}-${PKG_RELEASE}/percona-xtradb-cluster-${PXC_VERSION}-r0.apk" -o "percona-xtradb-cluster-${PXC_VERSION}-r0.apk"; \
    curl -fSL "https://github.com/Flowman/pxc-alpine/releases/download/${PXC_VERSION}-${PKG_RELEASE}/percona-xtrabackup-${XTRABACKUP_VERSION}-r0.apk" -o "percona-xtrabackup-${XTRABACKUP_VERSION}-r0.apk"; \
    apk add --allow-untrusted --no-cache \
        percona-xtradb-cluster-client-${PXC_VERSION}-r0.apk \
        percona-xtradb-cluster-common-${PXC_VERSION}-r0.apk \
        percona-xtradb-cluster-${PXC_VERSION}-r0.apk \
        percona-xtrabackup-${XTRABACKUP_VERSION}-r0.apk; \
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
