#!/bin/bash -x
set -e

. config.rc

sed -e "s/LDAP_SERVER/${LDAP_SERVER}/g" httpd/vhost.conf.templ > httpd/vhost.conf
sed -i "s/LDAP_ROOT_DN/${LDAP_ACCOUNTBASE}/g" httpd/vhost.conf

# Create Apache volume.
docker volume create --name ${FORGE_PREFIX}-${APACHE_VOLUME}

docker run  \
  --name ${FORGE_PREFIX}-${APACHE_NAME} \
  --detach \
  --net ${CI_NETWORK} \
  -p ${HTTPD_PORT}:80 \
  -v ${PWD}/httpd/httpd.conf:/usr/local/apache2/conf/httpd.conf \
  -v ${PWD}/httpd/vhost.conf:/usr/local/apache2/conf/vhost.conf \
  -v ${FORGE_PREFIX}-${APACHE_VOLUME}:/usr/local/apache2/www \
  ${HTTP_IMAGE_NAME}

