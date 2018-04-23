FROM alpine:3.6

CMD ["/usr/sbin/crond","-d","7","-f"]

RUN apk add --no-cache libxslt curl zabbix-utils

ADD egauge-to-zabbix.xsl egauge-poller.sh crontab /root/

RUN chmod +x /root/egauge-poller.sh && crontab /root/crontab

ENV SP_EGAUGE_URI="http://solar/cgi-bin/egauge?v1&inst&tot" SP_ZABBIX_SERVER="127.0.0.1" SP_ZABBIX_PORT="10051"
