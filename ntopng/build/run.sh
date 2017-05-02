#!/bin/bash
service redis-server start
service nprobe start
ntopng /etc/ntopng/ntopng.conf "$@"
