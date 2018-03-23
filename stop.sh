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

docker stop ${CONTAINERS[@]}
