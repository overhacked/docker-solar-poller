## Standard phusion part
FROM phusion/baseimage:latest
ENV HOME /root
#RUN /etc/my_init.d/00_regen_ssh_host_keys.sh                            # Uncomment to Enable SSHD
RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh    # Uncomment to Disable SSHD
CMD ["/sbin/my_init"]

## Expose ports.
EXPOSE 53 53/udp

## Application specific part
MAINTAINER Stephen Day <sd@unixtastic.com>
WORKDIR /tmp
RUN apt-get -qq update && apt-get -qq upgrade
RUN apt-get -qq install gcc make wget libssl-dev
RUN wget -q -O bind-9.9.5-P1.tar.gz http://www.isc.org/downloads/file/bind-9-9-5-w1/?version=tar.gz
RUN tar -xzf bind-9.9.5-P1.tar.gz
WORKDIR /tmp/bind-9.9.5-P1
RUN ./configure --with-openssl --disable-linux-caps
RUN make
RUN groupadd bind && useradd -g bind -d /tmp -M -r -s /bin/false bind
RUN make install
ADD named.conf /etc/named.conf
RUN mkdir /var/log/bind && chown bind:bind /var/log/bind
RUN mkdir -p /var/named/zones/slave && chown bind:bind /var/named/zones/slave
RUN rndc-confgen >/etc/rndc.conf
RUN sed -i "s%^.*_RNDC_SECRET_GOES_HERE_.*$%`grep -m 1 'secret' /etc/rndc.conf`%" /etc/named.conf

## Setup service
RUN mkdir /etc/service/bind
RUN echo "#!/bin/sh" >/etc/service/bind/run
RUN echo "exec /usr/local/sbin/named -g -4 -c /etc/named.conf -u bind" >>/etc/service/bind/run
RUN chmod +x /etc/service/bind/run

## Clean up
WORKDIR /
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

