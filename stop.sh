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
)

docker stop ${CONTAINERS[@]}
