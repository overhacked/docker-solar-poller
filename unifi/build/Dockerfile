FROM openjdk:8-alpine

ARG UNIFI_VERSION
ENV UNIFI_PKG_FILE=/tmp/unifi.deb

RUN apk add --no-cache mongodb binutils

WORKDIR /app
ADD install_unifi.sh /tmp/
RUN apk --no-cache add --virtual build-dependencies wget dpkg tar

RUN wget -q -O /tmp/unifi.deb http://dl.ubnt.com/unifi/${UNIFI_VERSION}/unifi_sysvinit_all.deb

RUN /bin/sh /tmp/install_unifi.sh \
  && apk --no-cache del build-dependencies \
  && rm -rf /tmp/unifi.deb /tmp/install_unifi.sh
COPY unifi.init /app/bin/unifi.init

CMD ["/app/bin/unifi.init"]

VOLUME /app/data
# https://help.ubnt.com/hc/en-us/articles/218506997-UniFi-Ports-Used
EXPOSE 8443 8880 8843 8080 6789 3478/udp 10001/udp 5656-5699/udp
