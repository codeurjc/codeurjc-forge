#!/bin/bash 
set -e

. config.rc

# Check if $CI_NETWORK already exists
if [ -z $(docker network ls | grep $CI_NETWORK) ]; then
  docker network create $CI_NETWORK
fi

# Launching LDAP
./createOpenLDAP.sh

# Launching GERRIT
export LDAP_SERVER=${FORGE_PREFIX}-${LDAP_NAME}:389
export PUBLIC_IP=$(ip route get 8.8.8.8 | head -1 | cut -d' ' -f8)
export GERRIT_WEBURL=http://${PUBLIC_IP}

./createGerrit.sh 
until curl --location --output /dev/null --silent --write-out "%{http_code}\\n" "http://localhost:${GERRIT_PORT}/" | grep 200 &>/dev/null
do
  echo "Waiting for Gerrit"
  sleep 1
done

# Launching JENKINS
./createJenkins.sh
until curl --location --output /dev/null --silent --write-out "%{http_code}\\n" "http://localhost:${JENKINS_PORT}/jenkins" | grep 200 &>/dev/null
do
  echo "Waiting for Jenkins"
  sleep 1
done

# Launching Apache
./createApache.sh

# Launching ARCHIVA
./createArchiva.sh

# Launching phpLDAPadmin
./createphpLDAPAdmin.sh

# Launching Self Service Password
./createLDAPSSP.sh

echo "##################"
echo "###    Done    ###"
echo "##################"
echo ""
echo "- URLs:"
echo ""
echo "Gerrit                -> ${GERRIT_WEBURL}:${GERRIT_PORT}"
echo "Jenkins               -> http://${PUBLIC_IP}:${JENKINS_PORT}/jenkins"
echo "Archiva               -> http://${PUBLIC_IP}:${ARCHIVA_PORT}"
echo "phpLDAPadmin          -> http://${PUBLIC_IP}:${PHPLDAPADMIN_PORT}/phpldapadmin"
echo "Self Service Password -> http://${PUBLIC_IP}:${LDAPSSP_PORT}/ssp"
echo "Apache Service        -> http://${PUBLIC_IP}:${HTTPD_PORT}"
