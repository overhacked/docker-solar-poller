FROM node:8-alpine

RUN mkdir -p /app && \
	chown root:node /app && \
	chmod 755 /app

ARG ZM_GIT_REPO="https://github.com/bhuisgen/zabbix-monitor.git"
ARG ZM_GIT_BRANCH

RUN apk add --no-cache --virtual build-dependencies git

WORKDIR /usr/src/app
# COPY from clone in build context (better for caching)
COPY zabbix-monitor/ /usr/src/app/
# or clone directly into image:
#RUN git clone --depth 1 --progress ${ZM_GIT_BRANCH:+--branch }${ZM_GIT_BRANCH:-} ${ZM_GIT_REPO} /usr/src/app


RUN cp app/scripts/config.js.dist app/scripts/config.js && \
	npm install && \
	npm run build && \
	cd /app && \
	cp -r /usr/src/app/dist/* /app/ && \
	rm -rf /usr/src/app/* && \
	npm install http-server -g

WORKDIR /app

RUN apk del build-dependencies && \
	npm cache clean --force && \
	rm -rf /tmp/*

ENV NODE_ENV production
USER node

EXPOSE 8080
CMD ["http-server","/app"]
