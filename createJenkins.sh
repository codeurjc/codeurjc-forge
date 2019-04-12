#!/bin/bash
set -e

. config.rc

# Create Jenkins volume.
docker volume create --name ${FORGE_PREFIX}-${JENKINS_VOLUME}

# Start Jenkins.
docker run \
--name ${FORGE_PREFIX}-${JENKINS_NAME} \
--net ${CI_NETWORK} \
-p 50000:50000 \
-p ${JENKINS_PORT}:8080 \
--volume ${FORGE_PREFIX}-${JENKINS_VOLUME}:/var/jenkins_home \
--volume /var/run/docker.sock:/var/run/docker.sock \
-e JAVA_OPTS="-Duser.timezone=${TIMEZONE} -Djenkins.install.runSetupWizard=false" \
-e JENKINS_ADMIN_USER=${ADMIN_UID} \
-e JENKINS_ADMIN_PASS=${ADMIN_PWD} \
-e JENKINS_DEV_USER=${DEVELOPER1_USERNAME} \
-e JENKINS_DEV_PASS=${DEVELOPER1_PASSWORD} \
--detach ${JENKINS_IMAGE_NAME} ${JENKINS_OPTS}

until curl --location --output /dev/null --silent --write-out "%{http_code}\\n" "http://localhost:${JENKINS_PORT}/jenkins" | grep 403 &>/dev/null
do
  echo -e "${YELLOW}Waiting for Jenkins${NC}"
  sleep 1
done