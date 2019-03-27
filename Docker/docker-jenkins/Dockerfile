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

# Install plugins
RUN /usr/local/bin/install-plugins.sh \
  ace-editor \
  branch-api \
  cloudbees-folder \
  command-launcher \
  config-file-provider \
  credentials \
  custom-tools-plugin \
  docker-build-publish \
  docker-plugin \
  docker-workflow \
  git \
  gitlab-plugin \
  git-server \
  handlebars \
  jquery-detached \
  matrix-auth \
  maven-plugin \
  momentjs \
  parameterized-trigger \
  pipeline-build-step \
  pipeline-graph-analysis \
  pipeline-input-step \
  pipeline-milestone-step \
  pipeline-model-api \
  pipeline-model-declarative-agent \
  pipeline-model-definition \
  pipeline-model-extensions \
  pipeline-rest-api \
  pipeline-stage-step \
  pipeline-stage-tags-metadata \
  pipeline-stage-view \
  swarm \
  workflow-aggregator \
  workflow-basic-steps \
  workflow-cps \
  workflow-cps-global-lib \
  workflow-durable-task-step \
  workflow-multibranch \
  ws-cleanup 

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
