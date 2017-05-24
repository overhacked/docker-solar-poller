#!/bin/sh -e

PATH=/sbin:/bin:/usr/sbin:/usr/bin

check_network() {
    if [ -x /usr/bin/uname ] && [ "X$(/usr/bin/uname -o)" = XSolaris ]; then
        IFCONFIG_OPTS="-au"
    else
        IFCONFIG_OPTS=""
    fi
    if [ -z "$(/sbin/ifconfig $IFCONFIG_OPTS)" ]; then
       return 1
    fi
    return 0
}

modprobe capability >/dev/null 2>&1 || true

# dirs under /run can go away on reboots.
mkdir -p /run/named
chmod 775 /run/named
chown root:bind /run/named >/dev/null 2>&1 || true

if [ ! -x /usr/sbin/named ]; then
    echo '/usr/sbin/named binary missing'
    exit 1
fi

if ! check_network; then
    echo "no networks configured"
    exit 1
fi

exec /usr/sbin/named -u bind -f $NAMED_OPTIONS
