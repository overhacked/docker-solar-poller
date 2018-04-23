FROM alpine:3.6
RUN apk --no-cache add --virtual build-deps curl unzip

ENV MICROMDM_VERSION=v1.2.0
RUN cd /tmp && \
    curl -OL https://github.com/micromdm/micromdm/releases/download/${MICROMDM_VERSION}/micromdm_${MICROMDM_VERSION}.zip && \
	unzip micromdm_${MICROMDM_VERSION}.zip && \
	mkdir /app && \
	mv build/linux/mdmctl build/linux/micromdm /app && \
    chmod a+x /app/micromdm /app/mdmctl && \
	rm -rf /tmp/build /tmp/micromdm_${MICROMDM_VERSION}.zip

RUN apk --no-cache del build-deps && \
	apk --no-cache add ca-certificates

ENV MM_APNS_CERT="/conf/apns.pem" MM_APNS_KEY="/conf/apns.key" MM_APNS_PASSWORD="" MM_FILE_REPO="/data" MM_CTL_ENABLED="false"
# Also available to override defaults:
# MM_SERVER_LISTEN=":https"
# MM_SERVER_TLS="true"
# MM_SERVER_URL="https://micromdm"
# MM_SERVER_DEBUG="false"
# MM_API_KEY will be randomly generated on first run and saved in /conf/api_key unless specified
VOLUME /conf /data /var/db/micromdm
EXPOSE 8080
ADD run.sh /
CMD ["/run.sh"]
