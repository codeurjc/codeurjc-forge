FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive

# Install Software
RUN apt-get update && \
    apt-get install -qqy --no-install-recommends \
    xvfb \
    wget \
    curl \
    openjdk-8-jdk \
    maven

# Install Chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
  && apt-get update -qqy \
  && apt-get -qqy install \
    google-chrome-stable \
  && rm /etc/apt/sources.list.d/google-chrome.list
COPY wrap_chrome_binary /opt/bin/wrap_chrome_binary
RUN /opt/bin/wrap_chrome_binary

ENV DISPLAY :99.0

COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

ENTRYPOINT [ "/usr/local/bin/run.sh" ]

