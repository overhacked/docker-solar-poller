FROM php:5.6-fpm-alpine

# 9000 php-fpm
# 2055 netflow
# 6343 sFlow
# 4739 ipfix
EXPOSE 80 2055 6343 4739
WORKDIR /

RUN apk --no-cache add supervisor nginx nginx-common perl rrdtool perl-rrd nfdump nfprofile sfcapd tcpdump tzdata
RUN apk --no-cache add --virtual build-deps wget curl make gcc perl-dev perl-module-build musl-dev coreutils

RUN docker-php-ext-install -j$(nproc) sockets

ENV PERL_CPANM_OPT --verbose --mirror https://cpan.metacpan.org --mirror-only
#RUN cpanm Mail::Header Mail::Internet IO::Socket::SSL IO::Socket::IP LWP LWP::Protocol::https Sys::Syslog && rm -rf ~/.cpanm
RUN curl -sSL https://cpanmin.us | perl - Socket6 Mail::Header Mail::Internet Sys::Syslog && rm -rf ~/.cpanm
#ENV PERL_CPANM_OPT $PERL_CPANM_OPT --verify

# Add an account for NFSen as a member of the apache group
RUN adduser -D -u 99 -h /var/netflow -G www-data -s /bin/false netflow
RUN mkdir -p /data/nfsen && chown netflow /data/nfsen && chmod 755 /data/nfsen

ARG NFSEN_VERSION=1.3.8
ADD http://iweb.dl.sourceforge.net/project/nfsen/stable/nfsen-${NFSEN_VERSION}/nfsen-${NFSEN_VERSION}.tar.gz /tmp/nfsen-${NFSEN_VERSION}.tar.gz
RUN tar -C /tmp -xzf /tmp/nfsen-${NFSEN_VERSION}.tar.gz && rm /tmp/nfsen-${NFSEN_VERSION}.tar.gz

ADD nfsen.conf /conf/

ADD patches/ /tmp/nfsen-${NFSEN_VERSION}/local_patches/
RUN cd /tmp/nfsen-${NFSEN_VERSION}; for patchfile in /tmp/nfsen-${NFSEN_VERSION}/local_patches/*.patch; do echo $(basename $patchfile); patch -p0 -i $patchfile; done 
RUN cd /tmp/nfsen-${NFSEN_VERSION} && /sbin/syslogd -O /dev/null && perl ./install.pl /conf/nfsen.conf && cd / && rm -rf /tmp/nfsen-${NFSEN_VERSION}*; killall syslogd

RUN apk --no-cache del build-deps

ADD bootstrap.sh nginx.conf php-fpm.conf php-fpm_pool.conf /conf/

# Define maximum LOGLEVEL that busybox syslogd outputs
# All messages LESS THAN the specified level will be output
# https://en.wikipedia.org/wiki/Syslog#Severity_level
# Default (7) is max INFO (excludes DEBUG)
ENV LOGLEVEL=7 TZ=UTC
ADD supervisord.conf /etc/supervisord.conf

VOLUME /data/nfsen/plugins /data/nfsen/profiles-data /data/nfsen/profiles-stat /var/netflow
CMD ["/bin/sh","/conf/bootstrap.sh"]
