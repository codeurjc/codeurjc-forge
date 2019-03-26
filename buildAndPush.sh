#!/bin/bash -x
set -e

docker login -u $DOCKERHUB_USERNAME -p $DOCKERHUB_PASS
cd Docker
. versions

pushd docker-jenkins
docker build -t codeurjc/forge-jenkins .
docker tag codeurjc/forge-jenkins codeurjc/forge-jenkins:latest
docker tag codeurjc/forge-jenkins codeurjc/forge-jenkins:${TRAVIS_COMMIT}
docker tag codeurjc/forge-jenkins codeurjc/forge-jenkins:${JENKINS}
docker push codeurjc/forge-jenkins:latest
docker push codeurjc/forge-jenkins:${TRAVIS_COMMIT}
docker push codeurjc/forge-jenkins:${JENKINS}
popd

pushd gerrit-docker
docker build -t codeurjc/forge-gerrit .
docker tag codeurjc/forge-gerrit codeurjc/forge-gerrit:latest
docker tag codeurjc/forge-gerrit codeurjc/forge-gerrit:${TRAVIS_COMMIT}
docker tag codeurjc/forge-gerrit codeurjc/forge-gerrit:${GERRIT}
docker push codeurjc/forge-gerrit:latest
docker push codeurjc/forge-gerrit:${TRAVIS_COMMIT}
docker push codeurjc/forge-gerrit:${GERRIT}
popd

pushd ssp-docker
docker build -t codeurjc/forge-php-ssp .
docker tag codeurjc/forge-php-ssp codeurjc/forge-php-ssp:latest
docker tag codeurjc/forge-php-ssp codeurjc/forge-php-ssp:${TRAVIS_COMMIT}
docker tag codeurjc/forge-php-ssp codeurjc/forge-php-ssp:${SSP}
docker push codeurjc/forge-php-ssp:latest
docker push codeurjc/forge-php-ssp:${TRAVIS_COMMIT}
docker push codeurjc/forge-php-ssp:${SSP}
popd

docker logout
