#!/bin/bash 
set -eu -o pipefail

. config.rc

docker volume create --name ${FORGE_PREFIX}-${SONAR_VOLUME}

docker run \
  --name ${FORGE_PREFIX}-${SONAR_NAME} \
  --net ${CI_NETWORK} \
  -p ${SONAR_PORT}:9000 \
  --volume ${FORGE_PREFIX}-${SONAR_VOLUME}:/opt/sonarqube \
  --detach ${SONAR_IMAGE_NAME}

sleep 1

# Wait for sonarqube to be up and ready
TIMEOUT=60
i=0
set +e
while true; do
  LINE=$(docker logs --tail 1 ${FORGE_PREFIX}-${SONAR_NAME} 2>&1)
  echo $LINE | grep -q "SonarQube is up"
  if [ "$?" == "0" ]; then
    break;
  fi
  i=$(expr $i + 1)
  if [ "$i" == "$TIMEOUT" ]; then
    echo -e "${RED}Timeout${NC}"
    break;
  fi
  echo -e "${YELLOW}Waiting for SonarQube...${NC}"
  sleep 5
done
set -e

# Configuring
docker run \
  -t \
  --rm \
  --name codeurjc-forge-config-sonarqube \
  --net ${CI_NETWORK} \
  -e APP_URL=${FORGE_PREFIX}-${SONAR_NAME} \
  -e ADMIN_PWD=${ADMIN_PWD} \
  --volume ${PWD}/sonarqube:/workdir \
  --workdir /workdir \
  codeurjc/conf-sonar:latest
