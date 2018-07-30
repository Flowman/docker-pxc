[![](https://images.microbadger.com/badges/image/flowman/percona-xtradb-cluster:5.7.22-alpine.svg)](https://microbadger.com/images/flowman/percona-xtradb-cluster:5.7.22-alpine2 "Get your own image badge on microbadger.com")

# What is Percona XtraDB Cluster?

Percona XtraDB Cluster is High Availability and Scalability solution for MySQL Users. Percona XtraDB Cluster provides: Synchronous replication. Transaction either committed on all nodes or none. Multi-master replication.

## Info

This container is not meant to be run standalone as it is part of a Rancher 2.0 Catalog kubernetes helm chart [percona-xtradb-cluster](https://github.com/helm/charts/tree/master/stable/percona-xtradb-cluster). If it suites your purpose you are more then welcome to use it.

This image is based on the popular Alpine Linux project, available in the alpine official image. Alpine Linux is much smaller than most distribution base images (~5MB), and thus leads to much slimmer images in general.

This release has now dropped support for Rancher 1.x.

## Requirments

### Alpine Image

This image requires to run on Alpine v3.6 as PXC does not support the later version of libressl that is in the current Alpine images.

## Configuration

Refere to chart [configuration](https://github.com/helm/charts/tree/master/stable/percona-xtradb-cluster#configuration) for options.

## Usage

When configuring the chart, add answer `image.repository` flowman/percona-xtradb-cluster and `image.tag` 5.7.22-alpine.

## Build

For example, if you need to change anything, edit the Dockerfile and than build-it.

```bash
git clone git@github.com:Flowman/percona-xtradb-cluster.git
cd ./percona-xtradb-cluster
docker build -t flowman/percona-xtradb-cluster .
```
