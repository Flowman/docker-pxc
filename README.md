[![](https://images.microbadger.com/badges/image/flowman/percona-xtradb-cluster:5.7.16-alpine1.svg)](https://microbadger.com/images/flowman/percona-xtradb-cluster:5.7.16-alpine1 "Get your own image badge on microbadger.com")

# What is Percona XtraDB Cluster?

Percona XtraDB Cluster is High Availability and Scalability solution for MySQL Users. Percona XtraDB Cluster provides: Synchronous replication. Transaction either committed on all nodes or none. Multi-master replication.

## Info

This container is not meant to be run standalone as it is part of a [Rancher](http://rancher.com) Catalog item. If it suites your purpose you are more then welcome to use it.

This image is based on the popular Alpine Linux project, available in the alpine official image. Alpine Linux is much smaller than most distribution base images (~5MB), and thus leads to much slimmer images in general.

## Know Issues

[#6214](https://github.com/rancher/rancher/issues/6214) Do by no circumstances ever try to stop the service in rancher as this will kill the cluster and manual step is required to start it up again. PXC add an extra 10 sec delay when receiving a shutdown signal, and rancher uses docker stop that forcefully kills a container after 10 secs.

In case this happens follow these steps to fix it:

1. Stop the service
2. Check each container /var/lib/mysql/grastate.dat for the highest uuid
3. Change safe_to_bootstrap to 1 on the container with the highest uuid
4. Start only this container and check logs that it has bootstrapped successfully
5. Start the service again

The same issue will occur if trying to scale down the service to only 1 host.

## Requirments

### Discovery service

The cluster will try to register itself in Etcd, so that new nodes can easily find running nodes. This approach give more flexibility over the old rancher metadata that is read-only.

`DISCOVERY_SERVICE` optional `DISCOVERY_SERVICE_PORT`

This variable is mandatory and specifies the IP address or linked service hostname to the Etcd host.

`CLUSTER_NAME`

This variable is mandatory and specifies the cluster to join and register in Etcd.

## Recommendation

For persistent storage mount the `source:/var/lib/mysql` folder so you don't lose your data and for easy recovery when everything goes sideways.

Copy `node.cnf` and make required changes, and than mount it back to `source/node.cnf:/etc/mysql/conf.d/node.cnf`

## Environment Variables

When you start the pxc image, you can adjust the configuration of the pxc instance by passing one or more environment variables on the docker run command line. Do note that none of the variables below will have any effect if you start the container with a data directory that already contains a database: any pre-existing database will always be left untouched on container startup.

`MYSQL_ROOT_PASSWORD` or `MYSQL_RANDOM_ROOT_PASSWORD`

This variable is mandatory and specifies the password that will be set for the root superuser account.

`PXC_SST_PASSWORD`

This variable is mandatory and specifies the password that will be set for the sst account.

`MYSQL_DATABASE`

This variable is optional and allows you to specify the name of a database to be created on image startup. If a user/password was supplied (see below) then that user will be granted superuser access (corresponding to GRANT ALL) to this database.

`MYSQL_USER, MYSQL_PASSWORD`

These variables are optional, used in conjunction to create a new user and to set that user's password. This user will be granted superuser permissions (see above) for the database specified by the `MYSQL_DATABASE` variable. Both variables are required for a user to be created.

Do note that there is no need to use this mechanism to create the root superuser, that user gets created by default with the password specified by the `MYSQL_ROOT_PASSWORD` variable.

`MYSQL_ALLOW_EMPTY_PASSWORD`

This is an optional variable. Set to yes to allow the container to be started with a blank password for the root user. NOTE: Setting this variable to yes is not recommended unless you really know what you are doing, since this will leave your Percona instance completely unprotected, allowing anyone to gain complete superuser access.

## Usage

## ... via `docker-compose`

Example Rancher docker-compose stack

```yaml
version: '2'

services:
  pxc:
    image: flowman/percona-xtradb-cluster:5.7.16-alpine1
    environment:
      CLUSTER_NAME: pxc-cluster
      DISCOVERY_SERVICE: etcd
      MYSQL_ROOT_PASSWORD: password
      PXC_SST_PASSWORD: s3cretPass
    entrypoint:
    - /opt/rancher/start_etcd
    external_links:
    - etcd-ha/etcd:etcd
    volumes_from:
    - pxc-data
    labels:
      io.rancher.scheduler.affinity:container_label_soft_ne: io.rancher.stack_service.name=$${stack_name}/$${service_name}
      io.rancher.sidekicks: pxc-clustercheck,pxc-data
  pxc-data:
    image: flowman/percona-xtradb-cluster:5.7.16-alpine1
    environment:
      MYSQL_ALLOW_EMPTY_PASSWORD: 'yes'
    network_mode: none
    volumes:
    - /docker-entrypoint-initdb.d
    - /etc/mysql/conf.d
    - /etc/mysql/percona-xtradb-cluster.conf.d
    - /var/lib/mysql
    command:
    - /bin/true
    labels:
      io.rancher.container.start_once: 'true'
  pxc-clustercheck:
    image: flowman/percona-xtradb-cluster-clustercheck:v2.0
    network_mode: container:pxc
    volumes_from:
    - pxc-data
```

Example rancher-compose for monitoring pxc

```yaml
pxc:
  health_check:
    port: 8000
    interval: 2000
    unhealthy_threshold: 3
    strategy: none
    request_line: GET / HTTP/1.1
    healthy_threshold: 2
    response_timeout: 2000
```

Example docker-compose file

```yaml
version: '2'

services:
  pxc:
    image: flowman/percona-xtradb-cluster:5.7.16-alpine1
    environment:
      CLUSTER_NAME: pxc-cluster
      DISCOVERY_SERVICE: etcd
      MYSQL_ROOT_PASSWORD: password
      PXC_SST_PASSWORD: s3cretPass
    entrypoint: /opt/rancher/start_etcd
    volumes:
    - /docker-entrypoint-initdb.d
    - /etc/mysql/conf.d
    - /etc/mysql/percona-xtradb-cluster.conf.d
    - /var/lib/mysql
  pxc-clustercheck:
    image: flowman/percona-xtradb-cluster-clustercheck:v2.0
    network_mode: "service:pxc"
    volumes_from:
    - pxc
```

## Build

For example, if you need to change anything, edit the Dockerfile and than build-it.

```bash
git clone git@github.com:Flowman/percona-xtradb-cluster.git
cd ./percona-xtradb-cluster
docker build --rm -t flowman/percona-xtradb-cluster .
```