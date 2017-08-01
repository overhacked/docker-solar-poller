#!/bin/bash
config_file=${MINER_CONF:-/conf/unifi_proxy.conf}

# MINER_VarName env -> /app/unifi_proxy.conf: VarName $MINER_VarName
cp "$config_file" "${config_file}.orig"
# Delete existing directives
for e in ${!MINER_*}; do sed "/${e:6}/d" "$config_file" > "${config_file}.new"; done
# Add new directives
for e in ${!MINER_*}; do echo "${e:6}=${!e}" >> "${config_file}.new"; done
mv "${config_file}.new" "$config_file"

# Start unifi_proxy
exec perl /app/unifi_proxy.pl -C "$config_file"
