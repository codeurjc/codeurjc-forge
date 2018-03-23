#!/bin/bash

LDAP_NAME=${LDAP_NAME:-openldap}

if [ -n "$(docker ps -a | grep ${LDAP_NAME})" ]; then
  docker stop ${LDAP_NAME}
  docker rm -v ${LDAP_NAME}
fi

docker volume rm openldap-etc-volume
docker volume rm openldap-repo-volume
