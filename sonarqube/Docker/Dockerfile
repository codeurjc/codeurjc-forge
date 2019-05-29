FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive
ENV DISPLAY :99.0

# Install Software
RUN apt-get update && \
    apt-get install -qqy --no-install-recommends \
    xvfb \
    x11-utils \
    firefox \
    curl \
    python3 \
    python3-pip

COPY ./geckodriver /usr/local/bin/geckodriver
COPY run.sh /usr/local/bin/run.sh
COPY ./configSonarq.py /usr/local/bin/configSonarq.py
RUN pip3 install selenium
RUN chmod +x /usr/local/bin/run.sh

ENTRYPOINT [ "/usr/local/bin/run.sh" ]

