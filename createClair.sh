#!/bin/bash 
set -eu -o pipefail

. config.rc

docker volume create --name ${FORGE_PREFIX}-${CLAIR_PS_VOLUME}

# Configuring CLAIR
sed "s/POSTGRES_NAME/${FORGE_PREFIX}-${CLAIR_PS_NAME}/" clair/config.yaml.template > ${FORGE_CONFIG_DIR}/config-clair.yaml

docker run --detach \
  --name ${FORGE_PREFIX}-${CLAIR_PS_NAME} \
  --publish 5432:5432 \
  --net ${CI_NETWORK} \
  --volume ${FORGE_PREFIX}-${CLAIR_PS_VOLUME}:/var/lib/postgresql/data \
  arminc/clair-db:latest

# Wait for Postgres to be up and ready
TIMEOUT=60
i=0
set +e
while true; do
  LINE=$(docker logs --tail 1 ${FORGE_PREFIX}-${CLAIR_PS_NAME} 2>&1)
  echo $LINE | grep -q "database system is ready to accept connections"
  if [ "$?" == "0" ]; then
    break;
  fi
  i=$(expr $i + 1)
  if [ "$i" == "$TIMEOUT" ]; then
    echo -e "${RED}Timeout!${NC}"
    exit 1
  fi
  echo -e "${YELLOW}Waiting for Postgres...${NC}"
  sleep 5
done
set -e

docker run --detach \
  --name ${FORGE_PREFIX}-${CLAIR_NAME} \
  --net ${CI_NETWORK} \
  --publish ${CLAIR_PORT_1}:6060 \
  --publish ${CLAIR_PORT_2}:6061 \
  --volume ${FORGE_CONFIG_DIR}/config-clair.yaml:/config/config.yaml \
  ${CLAIR_IMAGE_NAME} -config /config/config.yaml



