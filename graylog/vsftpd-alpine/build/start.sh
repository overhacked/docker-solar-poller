#!/bin/sh

/sbin/syslogd -O /proc/1/fd/1
exec /usr/sbin/vsftpd /conf/vsftpd.conf -opasv_min_port=${PASV_PORT_MIN} -opasv_max_port=${PASV_PORT_MAX} -osyslog_enable=YES -oseccomp_sandbox=NO -obackground=NO
