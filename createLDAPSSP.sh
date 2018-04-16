#!/bin/bash

. config.rc

docker run \
-detach \
--name ${FORGE_PREFIX}-${OPENLDAP_SSP_NAME} \
--net ${CI_NETWORK} \
-p ${LDAPSSP_PORT}:80 \
-e LDAP_URL="ldap://${FORGE_PREFIX}-$LDAP_NAME:389" \
-e LDAP_BINDDN="cn=admin,${LDAP_ACCOUNTBASE}" \
-e LDAP_BINDPW="$SLAPD_PASSWORD" \
-e LDAP_BASE="$LDAP_ACCOUNTBASE" \
${OPENLDAP_SSP_IMAGE_NAME}


