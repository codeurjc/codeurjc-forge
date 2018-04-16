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
export LDAP_SERVER=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{ .IPAddress}}{{end}}' openldap):389
export PUBLIC_IP=$(ip route get 8.8.8.8 | head -1 | cut -d' ' -f8)
export GERRIT_WEBURL=http://${PUBLIC_IP}

./createGerrit.sh 
until curl --location --output /dev/null --silent --write-out "%{http_code}\\n" "http://localhost:8080/" | grep 200 &>/dev/null
do
  echo "Waiting for Gerrit"
  sleep 1
done

# Launching JENKINS
./createJenkins.sh
until curl --location --output /dev/null --silent --write-out "%{http_code}\\n" "http://localhost:9090/jenkins" | grep 200 &>/dev/null
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

echo "##################"
echo "###    Done    ###"
echo "##################"
echo ""
echo "- URLs:"
echo ""
echo "Gerrit       -> ${GERRIT_WEBURL}:${GERRIT_PORT}"
echo "Jenkins      -> http://${PUBLIC_IP}:9090/jenkins"
echo "Archiva      -> http://${PUBLIC_IP}:7070"
echo "phpLDAPadmin -> http://${PUBLIC_IP}:9292/phpldapadmin"
