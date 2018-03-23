#!/bin/bash
set -e
LDAP_NAME=${LDAP_NAME:-openldap}
LDAP_VOLUME=${LDAP_VOLUME:-openldap-volume}
SLAPD_PASSWORD=${SLAPD_PASSWORD:-$1}
SLAPD_DOMAIN=${SLAPD_DOMAIN:-$2}
LDAP_IMAGE_NAME=${LDAP_IMAGE_NAME:-openfrontier/openldap}

# Stop and delete openldap container.
if [ -z "$(docker ps -a | grep ${LDAP_VOLUME})" ]; then
  echo "${LDAP_VOLUME} does not exist."
  exit 1
elif [ -n "$(docker ps -a | grep ${LDAP_NAME} | grep -v ${LDAP_VOLUME})" ]; then
  docker stop ${LDAP_NAME}
  docker rm ${LDAP_NAME}
fi

#Start openldap
docker run \
--name ${LDAP_NAME} \
-p 389:389 \
--volumes-from ${LDAP_VOLUME} \
-e SLAPD_PASSWORD=${SLAPD_PASSWORD} \
-e SLAPD_DOMAIN=${SLAPD_DOMAIN} \
-d ${LDAP_IMAGE_NAME}
