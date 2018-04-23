#!/bin/bash -ex

# Config
/configure-ssp.sh

# start apache
exec /usr/sbin/apache2ctl -D FOREGROUND