#!/bin/bash -x
set -e

. config.rc

for container in $(docker ps -a --filter "name=${FORGE_PREFIX}*" --format "{{ .Names }}")
do
  docker start $container
done
