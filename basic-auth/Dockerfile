FROM --platform=$BUILDPLATFORM ubuntu/squid:latest
ARG TARGETARCH
ARG BUILDPLATFORM

RUN apt-get -qqy update && \
    apt-get -qqy install --no-install-recommends apache2-utils && \
    rm -rf /var/lib/apt/lists/*

COPY squid.conf /etc/squid/squid.conf
COPY entrypoint.sh /
RUN chmod a+x /entrypoint.sh

EXPOSE 3128

ENTRYPOINT ["/entrypoint.sh"]
