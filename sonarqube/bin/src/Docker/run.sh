#!/bin/bash -x
set -eu -o pipefail

# Launch XVFB
/usr/bin/Xvfb :99 -screen 0 1024x768x16 &

# Wait for XVFB
while ! xdpyinfo >/dev/null 2>&1
do
  sleep 0.50s
  echo "Waiting xvfb..."
done

until curl --output /dev/null --silent --write-out "%{http_code}\\n" "http://${APP_URL}:9000" | grep 200 &>/dev/null
do
  echo "Waiting for the app"
  sleep 1
done

# Launch test
mvn --batch-mode test
