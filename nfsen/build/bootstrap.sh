#!/bin/sh

set -e
set -u

# Supervisord default params
SUPERVISOR_PARAMS='--configuration=/etc/supervisord.conf'

update_config() {
  # ^FP_: /conf/php-fpm_pool.conf
  for i in $( printenv | grep ^FP_ | awk -F'=' '{print $1}' | sort -rn ); do
    reg=$(echo ${i} | sed 's|^FP_||' | sed -E "s/_[0-9]+$//")
    val=$(eval "echo \${$i}")
	sed -Ei "/^[[:blank:]]*${reg}\\>/d" /conf/php-fpm_pool.conf
    echo "php_value[${reg}]=${val}" >> /conf/php-fpm_pool.conf
  done

  # Make sure PHP has a timezone defined
  awk -e 'BEGIN{if (ENVIRON["TZ"]=="") {TZ="UTC"} else {TZ=ENVIRON["TZ"]}}; /^[[:blank:]]*php_value\[date\.timezone\][[:blank:]]*=/{FOUND=1;sub("=.*$","");print $0 "= " TZ;getline;}; 1; END{if (FOUND != 1) print "php_value[date.timezone]=" TZ}' /conf/php-fpm_pool.conf > /tmp/php-fpm_pool.conf.new
  mv /tmp/php-fpm_pool.conf.new /conf/php-fpm_pool.conf
}

update_config
exec supervisord --nodaemon $SUPERVISOR_PARAMS
