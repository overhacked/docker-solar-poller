FROM alpine:3.6

RUN apk add --no-cache perl-json-maybexs perl-cpanel-json-xs perl-libwww perl-lwp-protocol-https perl-io-socket-ssl perl-io-socket-inet6 perl-data-dumper perl-time-hires bash

WORKDIR /app
RUN apk --no-cache add --virtual build-dependencies wget \
  && wget https://raw.githubusercontent.com/zbx-sadman/unifi_proxy/master/usr/local/sbin/unifi_proxy.pl \
  && sed -i s/JSON::XS/JSON::MaybeXS/g /app/unifi_proxy.pl \
  && sed -i s/IO::Socket::INET/IO::Socket::INET6/g /app/unifi_proxy.pl \
  && sed -i '/use IO::Socket ();/a\\\
use IO::Socket::INET6 ();' /app/unifi_proxy.pl \
  && chmod 0755 /app/unifi_proxy.pl \
  && apk del build-dependencies

ADD run.sh unifi_proxy.conf /conf/
CMD ["/conf/run.sh"]

EXPOSE 8448
