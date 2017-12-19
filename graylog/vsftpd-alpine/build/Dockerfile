FROM alpine:3.6

RUN apk --no-cache add vsftpd

VOLUME /conf /ftp
RUN chown root:ftp /ftp && chmod 775 /ftp
COPY vsftpd.conf start.sh /conf/

ENV PASV_PORT_MIN=21001 PASV_PORT_MAX=21010

EXPOSE 21 ${PASV_PORT_MIN}-${PASV_PORT_MAX}
CMD ["/bin/sh","/conf/start.sh"]
