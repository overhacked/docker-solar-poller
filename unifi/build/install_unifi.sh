#!/bin/sh -xe

PKG=${UNIFI_PKG_FILE:-/tmp/unifi.deb}

if [ ! -f "$PKG" ]; then
	echo UniFi package does not exist at $PKG
	exit 1;
fi

dpkg-deb -R /tmp/unifi.deb /tmp/unifi-pkg || exit 1
cp -R /tmp/unifi-pkg/usr/lib/unifi/* /app
rm -rf /tmp/unifi-pkg
ln -sf `which mongod` /app/bin/mongod
rm -rf /app/conf
