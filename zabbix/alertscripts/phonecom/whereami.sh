#!/bin/sh

printf '%s\n' $(dirname $(readlink -f "$0"))
