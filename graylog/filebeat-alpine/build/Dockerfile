FROM alpine:3.6

RUN mkdir /opt /conf

ARG FILEBEAT_VERSION=5.6.2

ADD https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-${FILEBEAT_VERSION}-linux-x86_64.tar.gz /opt/
RUN tar -C /opt -xzf /opt/filebeat-${FILEBEAT_VERSION}-linux-x86_64.tar.gz && rm -f /opt/filebeat-${FILEBEAT_VERSION}-linux-x86_64.tar.gz && mv /opt/filebeat-${FILEBEAT_VERSION}-linux-x86_64 /opt/filebeat && mv /opt/filebeat/filebeat*.yml /opt/filebeat/filebeat.template* /conf

VOLUME /conf /opt/filebeat/data /opt/filebeat/logs

CMD ["/opt/filebeat/filebeat","-v","-e","-path.home","/opt/filebeat","-path.config","/conf","-c","filebeat.yml"]
