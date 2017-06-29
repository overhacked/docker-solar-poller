FROM phusion/baseimage:latest

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

ADD egauge-to-zabbix.xsl egauge-poller.sh crontab /root/

RUN crontab /root/crontab

ENV SP_EGAUGE_URI="http://solar/cgi-bin/egauge?v1&inst&tot" SP_ZABBIX_SERVER="127.0.0.1" SP_ZABBIX_PORT="10051"

RUN apt-get update 

RUN apt-get install -y xsltproc curl zabbix-agent && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN systemctl disable zabbix-agent
