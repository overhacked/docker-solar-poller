#!/bin/sh

PHONECOM_SENDER="+17704630677"
DEBUG=0

SCRIPTDIR=$(dirname $(readlink -f "$0"))
PHONECOM_BIN="$SCRIPTDIR/phonecom"
cd "$SCRIPTDIR"
RESPONSE=$( \
	"$PHONECOM_BIN" \
		$([ $DEBUG = 1 ] && printf "%s" "--verbose-mode") \
		-c create-account-sms \
		--to "${1:?Destination SMS number must be first argument.}" \
		--from "$PHONECOM_SENDER" \
		--text "${2:?Message content must be second argument.}" \
)

# The awk command finds the line that contains only 'API Response:',
# then starts printing after skipping the number of lines (2) defined
# by f
RESULT=$( \
	printf "%s" "$RESPONSE" \
	| awk 'f==1{print};f>1&&f--{next};/^API Response:$/{f=2}' \
	| jq \
		-r '.to[0].status' \
)

if [ "$RESULT" != "sent" ]; then
	[ $DEBUG = 1 ] && printf "%s" "$RESPONSE"
	exit 1;
fi

exit 0
