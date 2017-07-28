## Standard phusion part
FROM phusion/baseimage:latest
MAINTAINER Ross Williams <ross@manyfoldfarm.com>
ENV HOME /root

## Uncomment to Enable SSHD
#RUN /etc/my_init.d/00_regen_ssh_host_keys.sh -f                         
#RUN rm -f /etc/service/sshd/down

## Use a script instead of multiple RUN's to reduce the number of created layers.
RUN apt-get -qq update && apt-get -qq upgrade

## Uncomment the following to install BIND from package repository
RUN apt-get -qq install bind9 dnsutils
ADD named.conf.local named.conf.options /etc/bind/
RUN mkdir /var/log/bind && chown bind:bind /var/log/bind
RUN mkdir -p /var/named/zones/slave && chown bind:bind /var/named/zones/slave
ADD run.sh /etc/service/bind/run

## Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

## Expose ports & volumes
EXPOSE 53 53/udp

## Application specific part
CMD ["/sbin/my_init"]
