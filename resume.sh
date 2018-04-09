#!/bin/bash -x
set -e

CONTAINERS=(
  openldap
  pg-gerrit
  gerrit
  jenkins
  apache
  archiva
)

docker start ${CONTAINERS[@]}
