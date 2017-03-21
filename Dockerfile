FROM alpine:3.5

MAINTAINER Peter Szalatnay <theotherland@gmail.com>

RUN \
    addgroup -S mysql \
    && adduser -D -S -h /var/cache/mysql -s /sbin/nologin -G mysql mysql \
    && echo "@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    && apk add --update \
        curl \
        jq \
        pwgen \
        bash \
        tzdata \
        socat \
        iproute2 \
        gosu@testing \
    && cd /tmp \
    && curl -fSL "https://github.com/Flowman/pxc-alpine/releases/download/5.7.16-27.19/percona-xtradb-cluster-common-5.7.16-r0.apk" -o "percona-xtradb-cluster-common-5.7.16-r0.apk" \
    && curl -fSL "https://github.com/Flowman/pxc-alpine/releases/download/5.7.16-27.19/percona-xtradb-cluster-5.7.16-r0.apk" -o "percona-xtradb-cluster-5.7.16-r0.apk" \
    && curl -fSL "https://github.com/Flowman/pxc-alpine/releases/download/5.7.16-27.19/percona-xtradb-cluster-galera-5.7.16-r0.apk" -o "percona-xtradb-cluster-galera-5.7.16-r0.apk" \
    && curl -fSL "https://github.com/Flowman/pxc-alpine/releases/download/5.7.16-27.19/percona-xtrabackup-2.4.6-r0.apk" -o "percona-xtrabackup-2.4.6-r0.apk" \
    && apk add --allow-untrusted \
        percona-xtradb-cluster-common-5.7.16-r0.apk \
        percona-xtradb-cluster-5.7.16-r0.apk \
        percona-xtradb-cluster-galera-5.7.16-r0.apk \
        percona-xtrabackup-2.4.6-r0.apk \

    && rm -rf /tmp/* \

    && mkdir -p /opt/rancher \
    && curl -SL https://github.com/cloudnautique/giddyup/releases/download/v0.14.0/giddyup -o /opt/rancher/giddyup \
    && chmod +x /opt/rancher/giddyup \

    && sed -Ei 's/^(bind-address|log)/#&/' /etc/mysql/percona-xtradb-cluster.conf.d/mysqld.cnf \
    && printf 'skip-host-cache\nskip-name-resolve\n' | awk '{ print } $1 == "[mysqld]" && c == 0 { c = 1; system("cat") }' /etc/mysql/percona-xtradb-cluster.conf.d/mysqld.cnf > /tmp/mysqld.cnf \
    && mv /tmp/mysqld.cnf /etc/mysql/percona-xtradb-cluster.conf.d/mysqld.cnf

COPY ./start_pxc /opt/rancher
COPY ./docker-entrypoint.sh /
COPY ./clustercheckcron /usr/bin/clustercheckcron

RUN \
    chmod a+x /docker-entrypoint.sh \
    && chmod a+x /usr/bin/clustercheckcron

VOLUME ["/var/lib/mysql", "/run/mysqld", "/etc/mysql/conf.d", "/etc/mysql/percona-xtradb-cluster.conf.d"]

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 3306 4444 4567 4568

CMD ["mysqld"]