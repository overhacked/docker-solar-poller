#!/bin/sh
IFTTT_KEY="${3:-dzIXVbGyLkjMF1iXPT6oP2}"
IFTTT_EVENT="zabbix_alert"

RESULT="$( \
	jq \
		--null-input \
		--compact-output \
		--arg value1 "$1" \
		--arg value2 "$2" \
		'{value1: $value1, value2: $value2}' \
	| curl \
		--silent \
		--request POST \
		--header 'Accept: application/text' \
		--header 'Content-Type: application/json' \
		--data "@-" \
		"https://maker.ifttt.com/trigger/${IFTTT_EVENT}/with/key/${IFTTT_KEY}" \
)"

#printf "%s: %s,%s,%s\\n%s" "$(date +'%y-%m-%d %T')" "$1" "$2" "$3" "$RESULT">> /var/log/zabbix/push_zabbkit.log
