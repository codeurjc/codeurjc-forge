#!/bin/bash 
set -e

. config.rc

# Check if $CI_NETWORK already exists
if [ -z $(docker network ls | grep ${CI_NETWORK} | awk '{print $1}' ) ]; then
  docker network create ${CI_NETWORK}
fi

export PUBLIC_IP=$(ip route get 8.8.8.8 | head -1 | cut -d' ' -f8)

# Check if there is a previous launching
if [ -d "${FORGE_CONFIG_DIR}" ]; then
  echo -e "${RED}[ERROR] There is a config dir ${FORGE_CONFIG_DIR}.${NC}"
  echo "Try to run ./resume.sh or if you want a fresh start run:"
  echo ""
  echo "    sudo rm -rf ${FORGE_CONFIG_DIR} "
  exit 1
fi

# Launching GITLAB
./createGitlab.sh

# Launching JENKINS
./createJenkins.sh

# Launching CLAIR
./createClair.sh

echo ""
echo ""
echo -e "${GREEN}##################"
echo "###    Done    ###"
echo -e "##################${NC}"
echo ""
echo -e "${GREEN}### URLs:${NC}"
echo "--------------------"
echo "Jenkins Service  -> http://${PUBLIC_IP}:${JENKINS_PORT}/jenkins"
echo "Gitlab Service   -> http://${PUBLIC_IP}:${GITLAB_PORT}"
echo "Clair Service    -> http://${PUBLIC_IP}:${CLAIR_PORT_1}"

echo ""
echo ""
echo -e "${GREEN}### Credentials $NC"
echo "--------------------"
echo -e "Credentials for Gitlab: ${YELLOW}root${NC} and password: ${YELLOW}${ADMIN_PWD}${NC}"
echo -e "Credentials for Jenkins: ${YELLOW}admin${NC} and password: ${YELLOW}${ADMIN_PWD}${NC}"
echo -e "Credentials for non admin purposes: ${YELLOW}${DEVELOPER1_USERNAME}${NC} and password: ${YELLOW}${DEVELOPER1_PASSWORD}${NC}"