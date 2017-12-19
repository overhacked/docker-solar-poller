FROM python:3.6-alpine

ENV INF_ZABBIX_SERVER=zabbix INF_ZABBIX_PORT=10051 INF_ZABBIX_HOSTNAME=Infinias
EXPOSE 8080

COPY ./src /app

RUN pip install --no-cache-dir -r /app/requirements.txt

CMD python /app/iaevents-listener.py -z "$INF_ZABBIX_SERVER" -p "$INF_ZABBIX_PORT" -s "$INF_ZABBIX_HOSTNAME"
