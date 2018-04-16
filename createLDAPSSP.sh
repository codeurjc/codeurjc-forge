#!/bin/bash

. config.rc

docker run \
-detach \
--name openldap-ssp \
--net ${CI_NETWORK} \
-p 9191:80 \
-e LDAP_URL="ldap://$LDAP_NAME:389" \
-e LDAP_BINDDN="cn=admin,${LDAP_ACCOUNTBASE}" \
-e LDAP_BINDPW="$SLAPD_PASSWORD" \
-e LDAP_BASE="$LDAP_ACCOUNTBASE" \
openfrontier/ldap-ssp