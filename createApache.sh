#!/bin/bash -x
set -e

. config.rc

sed -e "s/LDAP_SERVER/${LDAP_SERVER}/g" httpd-docker/vhost.conf.templ > httpd-docker/vhost.conf
sed -i "s/LDAP_ROOT_DN/${LDAP_ACCOUNTBASE}/g" httpd-docker/vhost.conf

# Create Apache volume.
docker volume create --name ${APACHE_VOLUME}

docker run  \
  --name ${APACHE_NAME} \
  --detach \
  --net ${CI_NETWORK} \
  -p 80:80 \
  -v ${PWD}/httpd-docker/httpd.conf:/usr/local/apache2/conf/httpd.conf \
  -v ${PWD}/httpd-docker/vhost.conf:/usr/local/apache2/conf/vhost.conf \
  -v ${APACHE_VOLUME}:/usr/local/apache2/www \
  httpd

