FROM openfrontier/gerrit:latest

MAINTAINER zsx <thinkernel@gmail.com>

COPY gerrit-create-user.sh /usr/local/bin/gerrit-create-user.sh
COPY gerrit-upload-ssh-key.sh /usr/local/bin/gerrit-upload-ssh-key.sh
COPY gerrit-create-initial-project.sh /usr/local/bin/gerrit-create-initial-project.sh
COPY setupGerrit.sh /usr/local/bin/setupGerrit.sh
COPY gerrit-init.nohup /docker-entrypoint-init.d/gerrit-init.nohup
RUN chmod +x /usr/local/bin/*.sh /docker-entrypoint-init.d/gerrit-init.nohup
