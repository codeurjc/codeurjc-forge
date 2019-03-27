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

echo "##################"
echo "###    Done    ###"
echo "##################"
echo ""
echo "- URLs:"
echo ""
echo "Jenkins Service  -> http://${PUBLIC_IP}:${JENKINS_PORT}/jenkins"
echo "Archiva Service  -> http://${PUBLIC_IP}:${ARCHIVA_PORT}"
echo "Apache Service   -> http://${PUBLIC_IP}:${HTTPD_PORT}"
echo "Gitlab Service   -> http://${PUBLIC_IP}:${GITLAB_PORT}"

echo ""
echo ""
echo -e "${GREEN}### Deploy finished! $NC"
echo "--------------------"
echo -e "You can go now to http://localhost/ and login with user: ${YELLOW}root${NC} and password: ${YELLOW}${ADMIN_PWD}${NC}"
echo -e "Also, you can use an account for non admin purposes: ${YELLOW}developer${NC} and password: ${YELLOW}d3v3l0p3r${NC}"