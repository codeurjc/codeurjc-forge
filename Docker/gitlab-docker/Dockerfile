FROM gitlab/gitlab-ce

RUN apt-get update && apt-get install -y --no-install-recommends software-properties-common apt-transport-https && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable" && \
    apt-get update && \
    apt-get install -y docker-ce


