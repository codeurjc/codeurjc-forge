# openldap-docker

# Quickstart Instructions

## Create
Run: ./createOpenLDAP.sh <SLAPD_PASSWORD> <SLAPD_DOMAIN> <GERRIT_ADMIN_UID> <GERRIT_ADMIN_PWD> <GERRIT_ADMIN_EMAIL> <DOCKER_NETWORK>
Example: ./createOpenLDAP.sh admin123 mycompany.org gerrit-admin gerrit123 gerrit@mycompany.org host

## Destroy
Run: ./destroyOpenLDAP.sh
