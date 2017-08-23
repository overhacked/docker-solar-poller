#!/bin/sh
DOCKER_COMPOSE=~/.local/bin/docker-compose

"$DOCKER_COMPOSE" -f ${COMPOSE_FILE:=/storage/conf/docker/docker-compose.yml} exec frontend nginx -s reload
