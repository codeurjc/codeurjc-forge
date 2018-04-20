#!/bin/bash -x
set -e

. config.rc

# Start PostgreSQL.
docker volume create --name ${FORGE_PREFIX}-${PG_GERRIT_VOLUME}

docker run \
--name ${FORGE_PREFIX}-${PG_GERRIT_NAME} \
--net ${CI_NETWORK} \
--volume ${FORGE_PREFIX}-${PG_GERRIT_VOLUME}:/var/lib/postgresql/data \
-p 5432:5432 \
-e POSTGRES_USER=gerrit2 \
-e POSTGRES_PASSWORD=gerrit \
-e POSTGRES_DB=reviewdb \
--restart=unless-stopped \
-d ${POSTGRES_IMAGE_NAME}

until nc -z localhost 5432
do
        echo "Waiting for postgres"
        sleep 1
done

# Create Gerrit volume.
docker volume create --name ${FORGE_PREFIX}-${GERRIT_VOLUME}

# Start Gerrit.
docker run \
--name ${FORGE_PREFIX}-${GERRIT_NAME} \
--net ${CI_NETWORK} \
-p 29418:29418 \
-p ${GERRIT_PORT}:8080 \
--volume ${FORGE_PREFIX}-${GERRIT_VOLUME}:/var/gerrit/review_site \
-e WEBURL=${GERRIT_WEBURL}:${GERRIT_PORT} \
-e HTTPD_LISTENURL=${HTTPD_LISTENURL} \
-e DATABASE_TYPE=postgresql \
-e DB_PORT_5432_TCP_ADDR=${FORGE_PREFIX}-${PG_GERRIT_NAME} \
-e DB_PORT_5432_TCP_PORT=5432 \
-e DB_ENV_POSTGRES_DB=reviewdb \
-e DB_ENV_POSTGRES_USER=gerrit2 \
-e DB_ENV_POSTGRES_PASSWORD=gerrit \
-e AUTH_TYPE=LDAP \
-e LDAP_SERVER=${FORGE_PREFIX}-${LDAP_NAME} \
-e LDAP_ACCOUNTBASE=${LDAP_ACCOUNTBASE} \
-e SMTP_SERVER=${SMTP_SERVER} \
-e SMTP_USER=${SMTP_USER} \
-e SMTP_PASS=${SMTP_PASS} \
-e USER_EMAIL=${USER_EMAIL} \
-e JENKINS_EMAIL="jenkins@domain.local" \
-e GERRIT_INIT_ARGS='--install-plugin=download-commands --install-plugin=replication' \
-e INITIAL_ADMIN_USER=${GERRIT_ADMIN_UID} \
-e INITIAL_ADMIN_PASSWORD=${GERRIT_ADMIN_PWD} \
-e INITIAL_ADMIN_EMAIL=${GERRIT_ADMIN_EMAIL} \
-e JENKINS_HOST=${FORGE_PREFIX}-${JENKINS_NAME} \
-e GERRIT_DEVELOPER_EMAIL=${GERRIT_DEVELOPER_EMAIL} \
-e GERRIT_DEVELOPER_USERNAME=${GERRIT_DEVELOPER_USERNAME} \
-e GERRIT_DEVELOPER_PASSWORD=${GERRIT_DEVELOPER_PASSWORD} \
-e INITIAL_PROJECT_NAME=${INITIAL_PROJECT_NAME} \
-e INITIAL_PROJECT_DESCRIPTION="${INITIAL_PROJECT_DESCRIPTION}" \
-e GITWEB_TYPE=gitiles \
-d ${GERRIT_IMAGE_NAME}

