FROM alpine:3.6

MAINTAINER Peter Szalatnay <theotherland@gmail.com>

RUN addgroup -S mysql \
    && adduser -D -S -h /var/cache/mysql -s /sbin/nologin -G mysql mysql \
    && echo "@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    && apk add --update \
        curl \
        bash \
        pwgen \
        gosu@testing \
    && cd /tmp \
    && curl -fSL "https://github.com/Flowman/pxc-alpine/releases/download/5.7.24-31.33/percona-xtradb-cluster-common-5.7.24-r0.apk" -o "percona-xtradb-cluster-common-5.7.24-r0.apk" \
    && curl -fSL "https://github.com/Flowman/pxc-alpine/releases/download/5.7.24-31.33/percona-xtradb-cluster-server-5.7.24-r0.apk" -o "percona-xtradb-cluster-server-5.7.24-r0.apk" \
    && curl -fSL "https://github.com/Flowman/pxc-alpine/releases/download/5.7.24-31.33/percona-xtradb-cluster-client-5.7.24-r0.apk" -o "percona-xtradb-cluster-client-5.7.24-r0.apk" \
    && curl -fSL "https://github.com/Flowman/pxc-alpine/releases/download/5.7.24-31.33/percona-xtradb-cluster-galera-5.7.24-r0.apk" -o "percona-xtradb-cluster-galera-5.7.24-r0.apk" \
    && curl -fSL "https://github.com/Flowman/pxc-alpine/releases/download/5.7.24-31.33/percona-xtrabackup-2.4.13-r0.apk" -o "percona-xtrabackup-2.4.13-r0.apk" \
    && apk add --allow-untrusted \
        percona-xtradb-cluster-common-5.7.24-r0.apk \
        percona-xtradb-cluster-client-5.7.24-r0.apk \
        percona-xtradb-cluster-galera-5.7.24-r0.apk \
        percona-xtrabackup-2.4.13-r0.apk \
        percona-xtradb-cluster-server-5.7.24-r0.apk \
    && mv /etc/mysql/percona-xtradb-cluster.conf.d/wsrep.cnf /etc/mysql/percona-xtradb-cluster.conf.d/wsrep.old \
    && rm -rf /tmp/*

VOLUME ["/var/lib/mysql", "/run/mysqld", "/etc/mysql/conf.d", "/etc/mysql/percona-xtradb-cluster.conf.d"]

COPY ./docker-entrypoint.sh /

RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 3306 4444 4567 4568

CMD ["mysqld"]