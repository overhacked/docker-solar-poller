FROM openjdk:8-jre-slim

CMD ["/root/unifi.init"]

VOLUME /usr/lib/unifi/data
# https://help.ubnt.com/hc/en-us/articles/218506997-UniFi-Ports-Used
EXPOSE 8443 8880 8843 8080 6789 3478/udp 10001/udp 5656-5699/udp

RUN apt-get update && apt-get install -y gnupg2

ARG UNIFI_VERSION
ARG UNIFI_DEB_URL
ADD 100-ubnt.list /etc/apt/sources.list.d/100-ubnt.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv 06E85760C0A52C50 \
	&& apt-get update \
	&& ( \
		if [ "${UNIFI_DEB_URL:-undefined}" != "undefined" ]; then \
		  apt-get install -y wget \
		  && wget -q -O /tmp/unifi.deb "${UNIFI_DEB_URL}" \
		  && dpkg -i /tmp/unifi.deb \
		  || apt-get -fy install; \
		else \
		  apt-get install -y unifi${UNIFI_VERSION:+=}${UNIFI_VERSION}${UNIFI_VERSION:+*}; \
		fi \
	   ) \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/lib/unifi

COPY unifi.init /root/unifi.init
