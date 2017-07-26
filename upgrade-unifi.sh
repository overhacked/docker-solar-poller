#!/bin/sh
COMPOSE_BIN='/usr/local/bin/docker-compose'
COMPOSE_FILE=${COMPOSE_FILE:-/storage/conf/docker/docker-compose.yml}
CONTAINER_VERSION_FILE='/app/webapps/ROOT/app-unifi/.version'
UNIFI_DATASET='storage/data/unifi'
MONGO_DATASET='storage/data/graylog/mongo'

USAGE="\\nUsage: `basename $0` [-hvn] [-s service_name] new_unifi_version\\n\\n-h Display this help message\\n-v Echo commands while running them\\n-n DRY RUN: output commands but don't run them (implies -v)\\n\\n-s service_name Specifies the docker-compose service name to upgrade (defaults to 'unifi')\\n\\nnew_unifi_version - Specifies the version to upgrade the container to\\n                    This script attempts to verify the number given is greater than the\\n                    current version.\\n\\n"

# Parse command line options.
DRY_RUN=
SERVICE='unifi'
while getopts hns: OPT; do
    case "$OPT" in
        h)
            printf "$USAGE"
            exit 0
            ;;
        n)
            DRY_RUN=echo
            ;;
        s)
            SERVICE=$OPTARG
            ;;
        \?)
            # getopts issues an error message
            printf "$USAGE" >&2
            exit 1
            ;;
    esac
done

# Remove the switches we parsed above.
shift `expr $OPTIND - 1`

# We want exactly one non-option argument. 
if [ $# -ne 1 ]; then
    printf "$USAGE" >&2
    exit 1
fi
TARGET_VERSION="$1"

[ -n "$DRY_RUN" ] && printf '*** DRY RUN ***\nThe following actions would be performed:\n'

# Version check
CURRENT_VERSION=`$COMPOSE_BIN exec $SERVICE awk -F. '{OFS=".";ORS=""; print $1,$2,$3}' "$CONTAINER_VERSION_FILE"`

if [ "$TARGET_VERSION" = "`printf '%s\n%s' $TARGET_VERSION $CURRENT_VERSION | sort -V | head -n1`" ]; then
    printf 'Specified version (%s) is less than or equal to installed version (%s)\n' $TARGET_VERSION $CURRENT_VERSION
    exit 1;
fi

COMPOSE_FILE_REGEX="UNIFI_VERSION[:=][[:space:]]*$CURRENT_VERSION"
if [ "`grep -E \"$COMPOSE_FILE_REGEX\" $COMPOSE_FILE | wc -l`" -ne 1 ]; then
    printf 'Running version number (%s) does not appear or appears more than one time in %s\n' $CURRENT_VERSION $COMPOSE_FILE
    exit 1;
fi

# Can we download the new version?
UNIFI_URL="http://dl.ubnt.com/unifi/${TARGET_VERSION}/unifi_sysvinit_all.deb" 
curl --output /dev/null --silent --head --fail "$UNIFI_URL" || { printf 'New version not available. Nothing to download at "%s".\n' "$UNIFI_URL"; exit 1; }

printf 'Upgrading from UniFi Controller version %s to version %s...\n\n' $CURRENT_VERSION $TARGET_VERSION

attempt() {
    printf "%s... " "$1"
    [ -n "$DRY_RUN" ] && printf '\n'
}
succeed() {
    echo 'done.'
}
attempt 'Obtaining sudo permissions'
$DRY_RUN sudo -v || { echo "Could not obtain sudo permissions."; exit 1; }
succeed
attempt "Stopping $SERVICE service"
$DRY_RUN $COMPOSE_BIN stop $SERVICE || { echo "Could not stop service \'$SERVICE\'."; exit 1; }
succeed
UNIFI_SNAPSHOT="${UNIFI_DATASET}@${CURRENT_VERSION}"
attempt "Taking ZFS snapshot $UNIFI_SNAPSHOT"
$DRY_RUN sudo zfs snapshot $UNIFI_SNAPSHOT || { printf 'Could not create ZFS snapshot %s.' $UNIFI_SNAPSHOT exit 1; }
succeed
if [ "$MONGO_DATASET" != "$UNIFI_DATASET" ]; then
    MONGO_SNAPSHOT="${MONGO_DATASET}@unifi-${CURRENT_VERSION}"
    attempt "Taking ZFS snapshot $MONGO_SNAPSHOT"
    $DRY_RUN sudo zfs snapshot $MONGO_SNAPSHOT || { printf 'Could not create ZFS snapshot %s.' $MONGO_SNAPSHOT; exit 1; };
    succeed
fi
attempt "Editing $COMPOSE_FILE (backed up to ${COMPOSE_FILE}.orig)"
$DRY_RUN sed -i'.orig' -r "/$COMPOSE_FILE_REGEX/s/$CURRENT_VERSION/$TARGET_VERSION/" "$COMPOSE_FILE" || { echo 'Could not edit Compose file to insert new version number.'; exit 1; }
succeed
attempt "Removing existing $SERVICE container(s) and volume(s)"
$DRY_RUN $COMPOSE_BIN rm -fv $SERVICE || { echo "Could not remove container(s) and volume(s) for service '$SERVICE'."; exit 1; }
succeed
$DRY_RUN $COMPOSE_BIN build $SERVICE || { echo "Could not build image for service '$SERVICE'."; exit 1; }
$DRY_RUN $COMPOSE_BIN create $SERVICE || { echo "Could not create container(s) for service '$SERVICE'."; exit 1; }
$DRY_RUN $COMPOSE_BIN start $SERVICE || { echo "Could not start service '$SERVICE'."; exit 1; }

echo 'Done!'
