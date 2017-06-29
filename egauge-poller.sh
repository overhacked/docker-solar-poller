#!/bin/sh

if [ -z "$SP_EGAUGE_URI" -o -z "$SP_ZABBIX_SERVER" ]; then
	echo \$SP_EGAUGE_URI or \$SP_ZABBIX_SERVER is unset. Exiting.
	exit 1;
fi

/usr/bin/curl -sS "$SP_EGAUGE_URI" | /usr/bin/xsltproc /root/egauge-to-zabbix.xsl - | /usr/bin/zabbix_sender --zabbix-server "$SP_ZABBIX_SERVER" --port "${SP_ZABBIX_PORT:-10051}" --with-timestamps -i -
