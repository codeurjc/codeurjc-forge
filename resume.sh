#!/bin/bash -x
set -e

. config.rc

CONTAINERS=(
  openldap
  pg-gerrit
  gerrit
  jenkins
  apache
  archiva
  $PHPLDAPADMIN_NAME
)

docker start ${CONTAINERS[@]}
