#!/bin/bash
set -eu -o pipefail

. config.rc

CONFIG_DIR=${FORGE_CONFIG_DIR}/gitlab
mkdir -p ${CONFIG_DIR}

# Volume for Gitlab runner
docker volume create --name ${FORGE_PREFIX}-${GITLAB_VOLUME_RUNNER}

JSON_FILE=$(mktemp -t file-XXX --suffix .json)

# Gitlab configuration file
sed "s/PASSWD/${ADMIN_PWD}/" gitlab.rb.template > gitlab.rb
sed -i "s/TOKEN/${GITLAB_RUNNER_REGISTRATION_TOKEN}/" gitlab.rb
mkdir -p ${CONFIG_DIR}/config
mv -v gitlab.rb ${CONFIG_DIR}/config

echo -e "${GREEN}### Starting Gitlab CE...$NC"
docker run --detach \
  --hostname ${FORGE_PREFIX}-${GITLAB_NAME} \
  --publish ${GITLAB_PORT}:80 --publish ${GITLAB_SSH_PORT}:22 \
  --name ${FORGE_PREFIX}-${GITLAB_NAME} \
  --net ${CI_NETWORK} \
  --volume ${CONFIG_DIR}/config:/etc/gitlab \
  --volume ${CONFIG_DIR}/logs:/var/log/gitlab \
  --volume ${CONFIG_DIR}/data:/var/opt/gitlab \
  ${GITLAB_IMAGE_NAME}
  

until curl --location --output /dev/null --silent --write-out "%{http_code}\\n" "http://localhost:${GITLAB_PORT}/" | grep 200 &>/dev/null
do
  echo -e "${YELLOW}Waiting for Gitlab...$NC"
  sleep 5s
done

echo -e "${GREEN}### Starting Gitlab runner...$NC"
docker run -detach \
  --name ${FORGE_PREFIX}-${GITLAB_RUNNER_NAME} \
  --net ${CI_NETWORK} \
  --volume ${FORGE_PREFIX}-${GITLAB_VOLUME_RUNNER}:/etc/gitlab-runner \
  --volume /var/run/docker.sock:/var/run/docker.sock \
  ${GITLAB_RUNNER_IMAGE_NAME}

echo -e "${YELLOW}Waiting for the runner...$NC"
sleep 5s

echo -e "${GREEN}### Configuring runner...$NC"
docker exec -t ${FORGE_PREFIX}-${GITLAB_RUNNER_NAME} /usr/bin/gitlab-runner register -n \
  --url ${GITLAB_URL} \
  --registration-token ${GITLAB_RUNNER_REGISTRATION_TOKEN} \
  --executor docker \
  --description "My Docker Runner" \
  --docker-image "docker:latest" \
  --docker-volumes /var/run/docker.sock:/var/run/docker.sock \
  --docker-network-mode ${CI_NETWORK}

echo -e "${GREEN}### Creating root access token $NC"
docker exec -t ${FORGE_PREFIX}-${GITLAB_NAME} sh -c "/opt/gitlab/embedded/bin/curl -o /create_token https://raw.githubusercontent.com/codeurjc/codeurjc-forge/master/Gitlab/create_admin_token; chmod +x /create_token; /create_token"

TOKEN=$(docker exec -t ${FORGE_PREFIX}-${GITLAB_NAME} cat /tmp/gitlab-root-personal-access-token.txt)

echo -e "${GREEN}### Creating user ${DEVELOPER1_USERNAME}... $NC"
cat>${JSON_FILE}<<EOF
{
  "email": "${DEVELOPER1_EMAIL}",
  "username": "${DEVELOPER1_USERNAME}",
  "name": "${DEVELOPER1_NAME}",
  "password": "${DEVELOPER1_PASSWORD}",
  "skip_confirmation": "true"
}
EOF
curl --header "Private-Token: ${TOKEN}" \
  -H 'Content-Type:application/json' \
  -H 'Accept:application/json' \
  -X POST \
  --data @${JSON_FILE} \
  http://localhost:${GITLAB_PORT}/api/v4/users

echo ""
echo ""
echo -e "${GREEN}### Creating RSA key for the developer user... $NC"
RSA_FILE=gitlab.pem
if [ ! -f ${RSA_FILE} ]; then
  ssh-keygen -t rsa -f ${RSA_FILE} -q -N ""
fi

RSA_FILE_PUB=$(echo -n $(cat ${RSA_FILE}.pub))

cat>${JSON_FILE}<<EOF
{
  "id": "2",
  "title": "developer key",
  "key": "${RSA_FILE_PUB}"
}
EOF

curl --header "Private-Token: ${TOKEN}" \
  -H 'Content-Type:application/json' \
  -H 'Accept:application/json' \
  -X POST \
  --data @${JSON_FILE} \
  http://localhost:${GITLAB_PORT}/api/v4/users/2/keys

echo ""
echo ""
echo -e "${GREEN}### Creating project for the user... $NC"
cat>${JSON_FILE}<<EOF
{
  "user_id": "2",
  "name": "${INITIAL_PROJECT_NAME}"
}
EOF

curl --header "Private-Token: ${TOKEN}" \
  -H 'Content-Type:application/json' \
  -H 'Accept:application/json' \
  -X POST \
  --data @${JSON_FILE} \
  http://localhost:${GITLAB_PORT}/api/v4/projects/user/2

echo ""
echo ""
echo -e "${GREEN}### Creating user ${CI_USERNAME}... $NC"
cat>${JSON_FILE}<<EOF
{
  "email": "${CI_EMAIL}",
  "username": "${CI_USERNAME}",
  "name": "${CI_NAME}",
  "password": "${CI_PASSWORD}",
  "skip_confirmation": "true"
}
EOF
curl --header "Private-Token: ${TOKEN}" \
  -H 'Content-Type:application/json' \
  -H 'Accept:application/json' \
  -X POST \
  --data @${JSON_FILE} \
  http://localhost:${GITLAB_PORT}/api/v4/users

echo ""
echo ""
echo -e "${GREEN}### Adding ${CI_USERNAME} to project ${INITIAL_PROJECT_NAME}... $NC"  
cat>${JSON_FILE}<<EOF
{
  "user_id": "3",
  "access_level": "30"
}
EOF

curl --header "PRIVATE-TOKEN: ${TOKEN}" \
  -H 'Content-Type:application/json' \
  -H 'Accept:application/json' \
  -X POST \
  --data @${JSON_FILE} \
  http://localhost:${GITLAB_PORT}/api/v4/projects/1/members

rm ${JSON_FILE}

