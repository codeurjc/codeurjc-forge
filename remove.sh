#!/bin/bash -x
set -e

CONTAINERS=(
  archiva
  jenkins
  gerrit
  pg-gerrit
  apache
  openldap
)

VOLUMES=(
  archiva-volume
  gerrit-volume
  jenkins-volume
  openldap-etc-volume
  openldap-repo-volume
  apache-volume
  pg-gerrit-volume
)

docker rm -f ${CONTAINERS[@]}
docker volume rm ${VOLUMES[@]}
