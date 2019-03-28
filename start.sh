#!/bin/bash 
set -e

. config.rc

# Check if $CI_NETWORK already exists
if [ -z $(docker network ls | grep ${CI_NETWORK} | awk '{print $1}' ) ]; then
  docker network create ${CI_NETWORK}
fi

export PUBLIC_IP=$(ip route get 8.8.8.8 | head -1 | cut -d' ' -f8)

# Launching Gitlab
./createGitlab.sh

# Launching JENKINS
./createJenkins.sh

# Launching Apache
./createApache.sh

# Launching ARCHIVA
./createArchiva.sh


echo ""
echo ""
echo -e "${GREEN}##################"
echo "###    Done    ###"
echo -e "##################${NC}"
echo ""
echo -e "${GREEN}### URLs:${NC}"
echo "--------------------"
echo "Jenkins Service  -> http://${PUBLIC_IP}:${JENKINS_PORT}/jenkins"
echo "Archiva Service  -> http://${PUBLIC_IP}:${ARCHIVA_PORT}"
echo "Apache Service   -> http://${PUBLIC_IP}:${HTTPD_PORT}"
echo "Gitlab Service   -> http://${PUBLIC_IP}:${GITLAB_PORT}"

echo ""
echo ""
echo -e "${GREEN}### Credentials $NC"
echo "--------------------"
echo -e "Credentials for Gitlab: ${YELLOW}root${NC} and password: ${YELLOW}${ADMIN_PWD}${NC}"
echo -e "Credentials for Jenkins: ${YELLOW}admin${NC} and password: ${YELLOW}${ADMIN_PWD}${NC}"
echo -e "Credentials for non admin purposes: ${YELLOW}${DEVELOPER1_USERNAME}${NC} and password: ${YELLOW}${DEVELOPER1_PASSWORD}${NC}"