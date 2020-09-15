#!/bin/sh
set -e

JVM_ARGS=${JVM_ARGS:="-Xmx1024m"}
JAVA_OPTS=${JAVA_OPTS:="-Dsun.net.inetaddr.ttl=30"}
INTERLOK_OPTS=${INTERLOK_OPTS:="bootstrap.properties"}
INTERLOK_BASE=${INTERLOK_BASE:="/opt/interlok"}

cd ${INTERLOK_BASE}
exec java $JVM_ARGS $JAVA_OPTS -jar lib/interlok-boot.jar $INTERLOK_OPTS
