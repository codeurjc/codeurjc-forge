#!/bin/bash -x
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
--volume ${FORGE_PREFIX}-${APACHE_VOLUME}:/usr/share/apache \
-e JAVA_OPTS="-Duser.timezone=${TIMEZONE} -Djenkins.install.runSetupWizard=false" \
-e LDAP_SERVER=${FORGE_PREFIX}-${LDAP_NAME} \
-e LDAP_ROOTDN=${LDAP_ACCOUNTBASE} \
-e LDAP_INHIBIT_INFER_ROOTDN=false \
-e LDAP_DISABLE_MAIL_ADDRESS_RESOLVER=false \
-e GERRIT_HOST_NAME=${FORGE_PREFIX}-${GERRIT_NAME} \
-e GERRIT_FRONT_END_URL=http://${PUBLIC_IP}:${GERRIT_PORT} \
-e GERRIT_INITIAL_ADMIN_USER=${GERRIT_ADMIN_UID} \
-e GERRIT_INITIAL_ADMIN_PASSWORD=${GERRIT_ADMIN_PWD} \
--detach ${JENKINS_IMAGE_NAME} ${JENKINS_OPTS}

