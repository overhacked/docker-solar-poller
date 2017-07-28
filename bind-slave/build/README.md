bind-DNSSEC-slave
=================

A minimal BIND based DNS slave for docker.

Build instructions:
===================

These instructions are to rebuild this image. Normally you would just follow
the usage instuctions below to run the image built by docker hub.

git clone https://github.com/unixtastic/bind-DNSSEC-slave

docker build -t 'unixtastic/bind-dnssec-slave' .

Usage instructions:
===================

First you need to setup your zones. Run the container with:

docker run -t -i unixtastic/bind-dnssec-slave /bin/bash

Edit /etc/named.conf to contain your TSIG key name(s) and value(s), your master server(s), and your zone(s).
The comments in the file should be helpful.

Check your config with: named-checkconf /etc/named.conf

Take a note of the container ID from the shell prompt, exit, and 
commit your changes:

docker commit -a 'Your Name' --run='{"Cmd": ["/sbin/my_init"]}' <container ID> YourName/DNS_slave_with_zones

Run your adjusted container:

docker run -d -p 53:53/udp -p 53:53 YourName/DNS_slave_with_zones

Test each of your zones with dig, i.e.:

dig <your FQDN> SOA @localhost


You may want to export the container and copy it to a different machine.


Notes:
======

This is a BIND based minimal DNS slave. It transfers zones from a DNS master and
serves them to anyone who asks. This is not a recursive DNS resolver and will only
serve zones it's been explictly told about.

This Dockerfile rebuilds BIND from the official ISC sources. The BIND
configuration is kept as minimal as practical.

Note that using the same DNS daemon as both a DNS server and a DNS resolver is not
considered best practice and may make cache poisioning or DOS attacks more likely.
This image is deliberately just a DNS slave server. As the resolver libraries have
no way to query on any port except 53 running a server and resolver on the
same IP isn't possible. You may run both on the same machine only if you use two
IPs.

TODO:

Consider adding reply rate limiting (RRL) to this.

Consider adding some easier way to setup zones. A single YAML or CSV config file would be good.

