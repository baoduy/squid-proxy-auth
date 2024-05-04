FROM --platform=$BUILDPLATFORM ubuntu:latest
ARG TARGETARCH
ARG BUILDPLATFORM

RUN rm -rf /var/lib/apt/lists/*
RUN apt-get -qqy update
RUN apt-get -qqy upgrade
RUN apt-get -qqy install apache2-utils
RUN apt-get -qqy install squid

COPY squid.conf /etc/squid/squid.conf
COPY entrypoint.sh /
RUN chmod a+x /entrypoint.sh

EXPOSE 3128
RUN mkdir -p /var/squid/cache && chown proxy -R /var/squid/cache

ENTRYPOINT ["/entrypoint.sh"]
