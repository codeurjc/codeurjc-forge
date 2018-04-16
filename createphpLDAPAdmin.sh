#!/bin/bash

. config.rc

docker run \
--detach \
--name ${FORGE_PREFIX}-${PHPLDAPADMIN_NAME} \
--net ${CI_NETWORK} \
-p ${PHPLDAPADMIN_PORT}:80 \
--env PHPLDAPADMIN_HTTPS=false \
--env PHPLDAPADMIN_LDAP_CLIENT_TLS=false \
--env PHPLDAPADMIN_LDAP_HOSTS="#PYTHON2BASH:[{'$FORGE_PREFIX-$LDAP_NAME': [{'server': [{'tls': False},{'port': 389},{'base': \"array('$LDAP_ACCOUNTBASE')\"}]},{'login': [{'bind_id': 'cn=admin,$LDAP_ACCOUNTBASE'},{'bind_pass': '$SLAPD_PASSWORD'}]}]}]" \
osixia/phpldapadmin:0.7.1
