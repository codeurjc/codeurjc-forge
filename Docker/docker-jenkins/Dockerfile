FROM jenkins/jenkins:lts
MAINTAINER zsx <thinkernel@gmail.com>

# Install docker binary
USER root

RUN apt-get update && apt-get install -y --no-install-recommends software-properties-common apt-transport-https && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable" && \
    apt-get update && \
    apt-get install -y docker-ce

RUN usermod -aG docker jenkins

# Creating a folder for artifacts
RUN mkdir -p /usr/share/apache && \
    chown 1000:1000 /usr/share/apache

USER jenkins

# Install plugins
RUN /usr/local/bin/install-plugins.sh \
  docker-build-publish \
  docker-plugin \
  gerrit-trigger \
  git \
  ldap \
  matrix-auth \
  maven-plugin \
  parameterized-trigger \
  command-launcher \
  pipeline-milestone-step \
  jquery-detached \
  ace-editor \
  workflow-cps \
  pipeline-input-step \
  pipeline-stage-step \
  pipeline-graph-analysis \
  pipeline-rest-api \
  handlebars \
  momentjs \
  pipeline-stage-view \
  pipeline-build-step \
  pipeline-model-api \
  pipeline-model-extensions \
  cloudbees-folder \
  git-server \
  workflow-cps-global-lib \
  branch-api \
  workflow-multibranch \
  workflow-durable-task-step \
  docker-workflow \
  pipeline-stage-tags-metadata \
  pipeline-model-declarative-agent \
  workflow-basic-steps \
  pipeline-model-definition \
  workflow-aggregator \
  swarm \
  ws-cleanup \
  config-file-provider \
  custom-tools-plugin

# Add groovy setup config
COPY init.groovy.d/ /usr/share/jenkins/ref/init.groovy.d/

# Add Jenkins URL and system admin e-mail config file
COPY jenkins.model.JenkinsLocationConfiguration.xml /usr/local/etc/jenkins.model.JenkinsLocationConfiguration.xml

# Add setup script.
COPY jenkins-setup.sh /usr/local/bin/jenkins-setup.sh

# Add cloud setting in config file.
COPY config.xml /usr/local/etc/config.xml

# Generate jenkins ssh key.
COPY generate_key.sh /usr/local/bin/generate_key.sh

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
