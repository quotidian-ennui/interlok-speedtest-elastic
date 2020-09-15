#!/usr/local/bin/dumb-init /bin/sh
/etc/init.d/filebeat start
exec /interlok-entrypoint.sh
