#!/bin/bash -x
set -e

. config.rc

docker volume create --name ${FORGE_PREFIX}-${ARCHIVA_VOLUME}

docker run \
--name ${FORGE_PREFIX}-${ARCHIVA_NAME} \
--net ${CI_NETWORK} \
--volume ${FORGE_PREFIX}-${ARCHIVA_VOLUME}:/archiva-data \
--publish ${ARCHIVA_PORT}:8080 \
--detach ${ARCHIVA_IMAGE_NAME}

until curl --location --output /dev/null --silent --write-out "%{http_code}\\n" "http://localhost:${ARCHIVA_PORT}/" | grep 200 &>/dev/null
do
  echo "Waiting for Archiva"
  sleep 1
done

generate_post_data()
{
  cat <<EOF
{
	"username":"admin",
	"password":"$GERRIT_ADMIN_PWD",
	"confirmPassword":"$GERRIT_ADMIN_PWD",
	"fullName":"URJC CI Forge",
	"email":"$GERRIT_ADMIN_EMAIL",
	"assignedRoles":[],
	"modified":true,
	"rememberme":false,
	"logged":false
}
EOF
}

curl "http://localhost:${ARCHIVA_PORT}/restServices/redbackServices/userService/createAdminUser" \
-H "Origin: http://localhost:${ARCHIVA_PORT}" \
-H "Content-Type: application/json" \
-H "Referer: http://localhost:${ARCHIVA_PORT}/" \
-H "Connection: keep-alive" \
--data "$(generate_post_data)" --compressed
