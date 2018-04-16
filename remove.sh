#!/bin/bash -x
set -e

. config.rc

for container in $(docker ps -a --filter "name=${FORGE_PREFIX}*" --format "{{ .Names }}")
do
  docker rm -f $container
done

for volume in $(docker volume ls --filter "name=${FORGE_PREFIX}*" --format "{{ .Name }}")
do
  docker volume rm $volume
done