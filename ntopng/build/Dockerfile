FROM ubuntu:14.04
MAINTAINER Ross Williams <ross@manyfoldfarm.com>

RUN apt-get update
RUN apt-get -y -q install curl
RUN curl -s --remote-name http://packages.ntop.org/apt/14.04/all/apt-ntop.deb
RUN dpkg -i apt-ntop.deb
RUN rm -rf apt-ntop.deb

RUN apt-get update && apt-get -y -q install ntopng redis-server libpcap0.8 libmysqlclient18 nprobe supervisor tcpdump
RUN mkdir -p /var/log/supervisor /var/run/redis && chown redis:redis /var/run/redis && chmod 755 /var/run/redis

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 3000
EXPOSE 2055/udp

COPY nprobe-none.conf /etc/nprobe/nprobe-none.conf
COPY ntopng.conf /etc/ntopng/ntopng.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

VOLUME /etc/ntopng
VOLUME /var/lib/redis

ENV NTOPARGS /etc/ntopng/ntopng.conf
CMD ["/usr/bin/supervisord","-c","/etc/supervisor/conf.d/supervisord.conf"]
