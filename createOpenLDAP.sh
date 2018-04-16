#!/bin/bash -x
set -e

. config.rc

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE_LDIF=base.ldif

#Convert FQDN to LDAP base DN
SLAPD_TMP_DN=".${SLAPD_DOMAIN}"
while [ -n "${SLAPD_TMP_DN}" ]; do
SLAPD_DN=",dc=${SLAPD_TMP_DN##*.}${SLAPD_DN}"
SLAPD_TMP_DN="${SLAPD_TMP_DN%.*}"
done
SLAPD_DN="${SLAPD_DN#,}"

#Create OpenLDAP volume.
docker volume create --name ${FORGE_PREFIX}-openldap-etc-volume
docker volume create --name ${FORGE_PREFIX}-openldap-repo-volume

#Create base.ldif
sed -e "s/{SLAPD_DN}/${SLAPD_DN}/g" ${DIR}/${BASE_LDIF}.template > ${DIR}/${BASE_LDIF}
sed -i "s/{ADMIN_UID}/${GERRIT_ADMIN_UID}/g" ${DIR}/${BASE_LDIF}
sed -i "s/{ADMIN_EMAIL}/${GERRIT_ADMIN_EMAIL}/g" ${DIR}/${BASE_LDIF}

sed -i "s/{DEVELOPER_USERNAME}/${GERRIT_DEVELOPER_USERNAME}/g" ${DIR}/${BASE_LDIF}
sed -i "s/{DEVELOPER_EMAIL}/${GERRIT_DEVELOPER_EMAIL}/g" ${DIR}/${BASE_LDIF}

#Start openldap
docker run \
--name ${FORGE_PREFIX}-${LDAP_NAME} \
--net ${CI_NETWORK} \
-p 389:389 \
--volume ${FORGE_PREFIX}-openldap-etc-volume:/etc/ldap \
--volume ${FORGE_PREFIX}-openldap-repo-volume:/var/lib/ldap \
-e SLAPD_PASSWORD=${SLAPD_PASSWORD} \
-e SLAPD_DOMAIN=${SLAPD_DOMAIN} \
-v ${DIR}/${BASE_LDIF}:/${BASE_LDIF}:ro \
-d ${LDAP_IMAGE_NAME}

while [ -z "$(docker logs ${FORGE_PREFIX}-${LDAP_NAME} 2>&1 | tail -n 4 | grep 'slapd starting')" ]; do
    echo "Waiting openldap ready."
    sleep 1
done

#Import accounts
docker exec ${FORGE_PREFIX}-${LDAP_NAME} \
ldapadd -f /${BASE_LDIF} -x -D "cn=admin,${SLAPD_DN}" -w ${SLAPD_PASSWORD}

# Admin user
docker exec ${FORGE_PREFIX}-${LDAP_NAME} \
ldappasswd -x -D "cn=admin,${SLAPD_DN}" -w ${SLAPD_PASSWORD} -s ${GERRIT_ADMIN_PWD} \
"uid=${GERRIT_ADMIN_UID},ou=accounts,${SLAPD_DN}"

# Developer user
docker exec ${FORGE_PREFIX}-${LDAP_NAME} \
ldappasswd -x -D "cn=admin,${SLAPD_DN}" -w ${SLAPD_PASSWORD} -s ${GERRIT_DEVELOPER_PASSWORD} \
"uid=${GERRIT_DEVELOPER_USERNAME},ou=accounts,${SLAPD_DN}"
