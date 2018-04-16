#!/bin/bash -x
set -e

. config.rc

# Create Jenkins volume.
docker volume create --name ${JENKINS_VOLUME}

# Start Jenkins.
docker run \
--name ${JENKINS_NAME} \
--net ${CI_NETWORK} \
-p 50000:50000 \
-p ${JENKINS_PORT}:${GERRIT_PORT} \
--volume ${JENKINS_VOLUME}:/var/jenkins_home \
--volume /var/run/docker.sock:/var/run/docker.sock \
--volume ${APACHE_VOLUME}:/usr/share/apache \
-e JAVA_OPTS="-Duser.timezone=${TIMEZONE} -Djenkins.install.runSetupWizard=false" \
-e LDAP_SERVER=${LDAP_SERVER} \
-e LDAP_ROOTDN=${LDAP_ACCOUNTBASE} \
-e LDAP_INHIBIT_INFER_ROOTDN=false \
-e LDAP_DISABLE_MAIL_ADDRESS_RESOLVER=false \
-e GERRIT_HOST_NAME=${GERRIT_NAME} \
-e GERRIT_FRONT_END_URL=http://${PUBLIC_IP}:${GERRIT_PORT} \
-e GERRIT_INITIAL_ADMIN_USER=${GERRIT_ADMIN_UID} \
-e GERRIT_INITIAL_ADMIN_PASSWORD=${GERRIT_ADMIN_PWD} \
--detach ${JENKINS_IMAGE_NAME} ${JENKINS_OPTS}

