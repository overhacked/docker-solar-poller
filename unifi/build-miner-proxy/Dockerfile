FROM perl:5.26

WORKDIR /app
EXPOSE 8448

ADD run.sh unifi_proxy.conf /conf/
CMD ["/conf/run.sh"]
RUN wget -q https://raw.githubusercontent.com/zbx-sadman/unifi_proxy/master/usr/local/sbin/unifi_proxy.pl \
  && chmod 0755 /app/unifi_proxy.pl

RUN cpanm Cpanel::JSON::XS JSON IO::Socket::IP IO::Socket::SSL LWP LWP::Protocol::https Data::Dumper
# ENV PERL_JSON_BACKEND has to come after the cpanm installation,
# because there is a circular dependency between Cpanel::JSON::XS
# and JSON when it is defined.
ENV PERL_JSON_BACKEND=Cpanel::JSON::XS
