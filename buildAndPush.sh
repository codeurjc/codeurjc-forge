#!/bin/bash -x
set -e

DATETIME=$(date +"%Y%m%d%H%M%S")

docker login -u $DOCKERHUB_USERNAME -p $DOCKERHUB_PASS

pushd docker-jenkins
docker build -t codeurjc/forge-jenkins .
docker tag codeurjc/forge-jenkins:latest
docker tag codeurjc/forge-jenkins:${DATETIME}
docker push codeurjc/forge-jenkins:latest
docker push codeurjc/forge-jenkins:${DATETIME}
popd

pushd gerrit-docker
docker build -t codeurjc/forge-gerrit .
docker tag codeurjc/forge-gerrit:latest
docker tag codeurjc/forge-gerrit:${DATETIME}
docker push codeurjc/forge-gerrit:latest
docker push codeurjc/forge-gerrit:${DATETIME}
popd

pushd ssp-docker
docker build -t codeurjc/forge-php-ssp .
docker tag codeurjc/forge-php-ssp:latest
docker tag codeurjc/forge-php-ssp:${DATETIME}
docker push codeurjc/forge-php-ssp:latest
docker push codeurjc/forge-php-ssp:${DATETIME}
popd

docker logout
