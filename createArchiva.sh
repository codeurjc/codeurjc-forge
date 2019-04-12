#!/bin/bash
set -e

. config.rc

CONFIG_DIR=${FORGE_CONFIG_DIR}/archiva
mkdir -p ${CONFIG_DIR}/conf
chmod -R 777 ${CONFIG_DIR}
cp -v archiva/archiva.xml ${CONFIG_DIR}/conf

docker run \
--name ${FORGE_PREFIX}-${ARCHIVA_NAME} \
--net ${CI_NETWORK} \
--volume ${CONFIG_DIR}:/archiva-data \
--publish ${ARCHIVA_PORT}:8080 \
--detach ${ARCHIVA_IMAGE_NAME}

until curl --location --output /dev/null --silent --write-out "%{http_code}\\n" "http://localhost:${ARCHIVA_PORT}/" | grep 200 &>/dev/null
do
  echo -e "${YELLOW}Waiting for Archiva${NC}"
  sleep 1
done

generate_admin_data()
{
  cat <<EOF
{
	"username":"admin",
	"password":"${ADMIN_PWD}",
	"confirmPassword":"${ADMIN_PWD}",
	"fullName":"URJC CI Forge",
	"email":"${ADMIN_EMAIL}",
	"assignedRoles":[],
	"modified":true,
	"rememberme":false,
	"logged":false
}
EOF
}

curl -v "http://localhost:${ARCHIVA_PORT}/restServices/redbackServices/userService/createAdminUser" \
-H "Origin: http://localhost:${ARCHIVA_PORT}" \
-H "Content-Type: application/json" \
-H "Referer: http://localhost:${ARCHIVA_PORT}/" \
-H "Connection: keep-alive" \
--data "$(generate_admin_data)" --compressed

echo ""

generate_user_data()
{
  cat <<EOF
{
	"username":"${DEVELOPER1_USERNAME}",
	"password":"${DEVELOPER1_PASSWORD}",
	"confirmPassword":"${DEVELOPER1_PASSWORD}",
	"fullName":"developer",
	"email":"${DEVELOPER1_EMAIL}",
	"modified":true,
	"rememberme":false,
	"logged":false,
	"validated":true
}
EOF
}

curl -v "http://localhost:${ARCHIVA_PORT}/restServices/redbackServices/userService/createUser" \
  -u admin:${ADMIN_PWD} \
  -H "Origin: http://localhost:${ARCHIVA_PORT}" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "Referer: http://localhost:${ARCHIVA_PORT}/" \
  -H "Connection: keep-alive" \
  --data "$(generate_user_data)" --compressed

echo ""

generate_user_role()
{
	cat <<EOF
{
	"username": "${DEVELOPER1_USERNAME}",
	"assignedRoles": ["Registered User", "Global Repository Manager", "Global Repository Observer"],
	"fullName":"developer",
	"email":"${DEVELOPER1_EMAIL}",
	"locked":false,
	"logged":false,
	"modified":true,
	"rememberme": false
}
EOF
}

curl -v "http://localhost:${ARCHIVA_PORT}/restServices/redbackServices/roleManagementService/updateUserRoles" \
  -u admin:${ADMIN_PWD} \
  -H "Origin: http://localhost:${ARCHIVA_PORT}" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "Referer: http://localhost:${ARCHIVA_PORT}/" \
  -H "Connection: keep-alive" \
  --data "$(generate_user_role)" --compressed

echo ""