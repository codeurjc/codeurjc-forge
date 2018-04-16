#!/bin/bash -x
set -e

. config.rc

CONTAINERS=(
  $PHPLDAPADMIN_NAME
  archiva
  jenkins
  gerrit
  pg-gerrit
  apache
  openldap
  openldap-ssp
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
