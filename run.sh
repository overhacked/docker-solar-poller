#!/bin/sh

APNS_CERT=${MM_APNS_CERT:-/conf/apns.pem}
APNS_KEY=${MM_APNS_KEY:-/conf/apns.key}
URL=${MM_SERVER_URL:-https://micromdm/}
TLS=${MM_SERVER_TLS:-true}
FILE_REPO=${MM_FILE_REPO:-/data}

if [ "$MM_API_KEY" ]; then
	API_KEY="$MM_API_KEY";
elif [ -r /conf/api_key ]; then
	API_KEY=$(cat /conf/api_key)
else
	API_KEY=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
	echo $API_KEY > /conf/api_key
	printf "API key not specified by \$MM_API_KEY or in /conf/api_key. Initialized to \"%s\" and saved in /conf/api_key.\n" "$API_KEY"
fi

[[ -z "$MM_CTL_ENABLED" || "$MM_CTL_ENABLED" = "false" ]] || /app/mdmctl config set -api-token="$API_KEY" -server-url="$URL"

exec /app/micromdm serve \
	-apns-cert="$APNS_CERT" \
	-apns-key="$APNS_KEY" \
	${API_KEY:+-api-key="$API_KEY"} \
	${MM_APNS_PASSWORD:+-apns-password="$MM_APNS_PASSWORD"} \
	${MM_SERVER_LISTEN:+-http-addr="$MM_SERVER_LISTEN"} \
	-server-url=$URL \
	${MM_SERVER_DEBUG:+-http-debug="$MM_SERVER_DEBUG"} \
	-tls=$TLS \
	${MM_SERVER_CERT:+-tls-cert="$MM_SERVER_CERT"} \
	${MM_SERVER_KEY:+-tls-key="$MM_SERVER_KEY"} \
	-filerepo="$FILE_REPO"
