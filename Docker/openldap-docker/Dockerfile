FROM dinkel/openldap

MAINTAINER mzp <qiuranke@gmail.com>

RUN apt-get update && apt-get install -y ldap-utils \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

