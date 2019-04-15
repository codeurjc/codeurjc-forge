#!/bin/bash 
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

echo -e "${GREEN}Some files under ${FORGE_CONFIG_DIR} are created by root and cannot be deleted by a regular user.${NC}"
echo    "Please, type your password when promted"
echo    ""
sudo rm -rf ${FORGE_CONFIG_DIR}
