FROM openjdk:8-jre-slim

CMD ["/root/unifi.init"]

VOLUME /usr/lib/unifi/data
# https://help.ubnt.com/hc/en-us/articles/218506997-UniFi-Ports-Used
EXPOSE 8443 8880 8843 8080 6789 3478/udp 10001/udp 5656-5699/udp

ADD 100-ubnt.list /etc/apt/sources.list.d/100-ubnt.list
RUN apt-get update && apt-get install -y gnupg2

ARG UNIFI_VERSION
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv 06E85760C0A52C50 \
	&& apt-get update \
	&& apt-get install -y unifi${UNIFI_VERSION:+=}${UNIFI_VERSION}${UNIFI_VERSION:+*} \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/lib/unifi

COPY unifi.init /root/unifi.init
