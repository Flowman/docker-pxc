[![](https://images.microbadger.com/badges/image/flowman/percona-xtradb-cluster:8.0.21-alpine.svg)](https://microbadger.com/images/flowman/percona-xtradb-cluster:8.0.21-alpine "Get your own image badge on microbadger.com")

# What is Percona XtraDB Cluster?

Percona XtraDB Cluster is High Availability and Scalability solution for MySQL Users. Percona XtraDB Cluster provides: Synchronous replication. Transaction either committed on all nodes or none. Multi-master replication.

## Info

This container is not meant to be run standalone as it is part of a kubernetes helm chart [percona-helm-charts](https://github.com/percona/percona-helm-charts). If it suites your purpose you are more then welcome to use it.

This image is based on the popular Alpine Linux project, available in the alpine official image. Alpine Linux is much smaller than most distribution base images (~5MB), and thus leads to much slimmer images in general.

## Requirments

### Alpine Image

This image requires to run on Alpine v3.13.2, as I manged to get 8.0 compiled on it.

## Configuration

Refere to chart [configuration](https://github.com/percona/percona-helm-charts/tree/main/charts/pxc-db) for options.

## Usage

When configuring the chart, add answer `pxc.image.repository` flowman/percona-xtradb-cluster and `pxc.image.tag` 8.0.21-alpine.

## Build

For example, if you need to change anything, edit the Dockerfile and than build-it.

```bash
git clone git@github.com:Flowman/percona-xtradb-cluster.git
cd ./percona-xtradb-cluster
docker build -t flowman/percona-xtradb-cluster .
```
