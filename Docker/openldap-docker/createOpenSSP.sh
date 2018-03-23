#!/bin/bash -x
set -e
LDAP_SSP_NAME=${LDAP_SSP_NAME:-ldap-ssp}
SLAPD_PASSWORD=${SLAPD_PASSWORD:-$1}
LDAP_SSP_IMAGE_NAME=${LDAP_SSP_IMAGE_NAME:-openfrontier/ldap-ssp}
CI_NETWORK=${CI_NETWORK:-ci-network}
LDAP_SERVER=172.19.0.2:389
LDAP_ACCOUNTBASE="dc=example,dc=com"
SLAPD_DN="dc=example,dc=com"

#Create OpenLDAP Self Service Password
docker run \
--name ${LDAP_SSP_NAME} \
--net ${CI_NETWORK} \
--restart=unless-stopped \
-p 8088:80 \
-e LDAP_URL=ldap://${LDAP_SERVER} \
-e LDAP_BASE=${LDAP_ACCOUNTBASE} \
-e LDAP_BINDDN=cn=admin,${SLAPD_DN} \
-e LDAP_BINDPW=${SLAPD_PASSWORD} \
-e SMTP_HOST=${SMTP_SERVER} \
-e SMTP_USER=${SMTP_USER} \
-e SMTP_PASS=${SMTP_PASS} \
-e MAIL_FROM=${USER_EMAIL} \
-d ${LDAP_SSP_IMAGE_NAME}
