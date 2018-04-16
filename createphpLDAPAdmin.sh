#!/bin/bash

. config.rc

docker run \
--detach \
--name ${PHPLDAPADMIN_NAME} \
--net ${CI_NETWORK} \
-p 9292:80 \
--env PHPLDAPADMIN_HTTPS=false \
--env PHPLDAPADMIN_LDAP_CLIENT_TLS=false \
--env PHPLDAPADMIN_LDAP_HOSTS="#PYTHON2BASH:[{'$LDAP_NAME': [{'server': [{'tls': False},{'port': 389},{'base': \"array('$LDAP_ACCOUNTBASE')\"}]},{'login': [{'bind_id': 'cn=admin,$LDAP_ACCOUNTBASE'},{'bind_pass': '$SLAPD_PASSWORD'}]}]}]" \
osixia/phpldapadmin:0.7.1