FROM perl:5.26

RUN cpanm JSON IO::Socket::IP IO::Socket::SSL LWP Data::Dumper

WORKDIR /app
RUN wget -q https://raw.githubusercontent.com/zbx-sadman/unifi_proxy/master/usr/local/sbin/unifi_proxy.pl \
  && chmod 0755 /app/unifi_proxy.pl

ADD run.sh unifi_proxy.conf /conf/
CMD ["/conf/run.sh"]

EXPOSE 8448
