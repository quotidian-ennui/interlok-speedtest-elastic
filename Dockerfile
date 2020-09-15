FROM azul/zulu-openjdk-alpine:8 as gradle_env

ARG java_tool_opts
ENV JAVA_TOOL_OPTIONS=$java_tool_opts
COPY . /root/builder

RUN cd /root/builder && \
    chmod +x /root/builder/gradlew && \
    ./gradlew --no-daemon assemble

# Use centos:7 as the image; it's glibc based so good for profiling.
# and because I'm familiar with the filebeat file structure layout
# so cut and paste development FTW
FROM centos:7

# This filebeats version matches my elastic version...
ARG FILEBEATS_RPM=https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.8.0-x86_64.rpm

COPY src/main/docker/docker-entrypoint.sh /docker-entrypoint.sh
COPY src/main/docker/interlok-entrypoint.sh /interlok-entrypoint.sh

# java because we love java
# curl because we love curl
# initscripts because /etc/init.d/filebeats requires the standard init functions.
RUN yum -y update && \
    yum -y install initscripts curl unzip java-1.8.0-openjdk java-1.8.0-openjdk-devel && \
    yum -y install ${FILEBEATS_RPM} && \
    curl -fsSL -o /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.1/dumb-init_1.2.1_amd64 && \
    chmod +x /usr/local/bin/dumb-init /docker-entrypoint.sh /interlok-entrypoint.sh && \
    yum -y clean all && \
    mkdir -p /opt/interlok/logs

COPY --from=gradle_env /root/builder/build/distribution /opt/interlok
COPY src/main/docker/filebeat.yml /etc/filebeat/filebeat.yml

ENV JAVA_TOOL_OPTIONS=""
ENV JAVA_OPTS="-Dsun.net.inetaddr.ttl=30"
ENV JVM_ARGS="-Xmx512M"
ENV INTERLOK_BASE="/opt/interlok"
ENV INTERLOK_OPTS="bootstrap.properties"
WORKDIR /opt/interlok/
EXPOSE 8080
ENTRYPOINT ["/docker-entrypoint.sh"]
