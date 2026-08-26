FROM alpine:3.21

RUN apk add --no-cache squid apache2-utils bash && \
    mkdir -p /var/spool/squid && chown squid:squid /var/spool/squid

COPY squid.conf /etc/squid/squid.conf
COPY entrypoint.sh /
RUN chmod a+x /entrypoint.sh

EXPOSE 3128

ENTRYPOINT ["/entrypoint.sh"]
