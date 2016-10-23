FROM debian:jessie

ENV DEBIAN_FRONTEND noninteractive

RUN useradd -d /app -r app && \
    mkdir -p /var/lib/xo-server && \
    chown -R app /var/lib/xo-server

WORKDIR /app

# Install requirements
RUN apt-get -qq update && \
    apt-get -qq install --no-install-recommends ca-certificates apt-transport-https \
    build-essential redis-server libpng-dev git python-minimal curl supervisor

RUN curl -o /usr/local/bin/n https://raw.githubusercontent.com/visionmedia/n/master/bin/n && \
        chmod +x /usr/local/bin/n && n 4.4.7

# Clone code
RUN git clone --depth=1 -b v4.17.0 http://github.com/vatesfr/xo-server && \
    git clone --depth=1 -b v4.16.0 http://github.com/vatesfr/xo-web && \
    rm -rf xo-server/.git xo-web/.git xo-server/sample.config.yaml

# Build dependancies then cleanup
RUN npm i -g npm@3.5.3
RUN cd xo-server/ && npm install && npm run build && cd ..
RUN cd xo-web/ && npm install && npm run build
RUN apt-get -qq purge build-essential make gcc git libpng-dev curl && \
    apt-get autoremove -qq && apt-get clean && \
    rm -rf /usr/share/doc /usr/share/man /var/log/* /tmp/* && \
    mkdir -p /var/log/redis

# Copy over entrypoint and daemon config files
COPY xo-server.yaml /app/xo-server/.xo-server.yaml
COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY redis.conf /etc/redis/redis.conf
COPY xo-entry.sh /

EXPOSE 8000

VOLUME ["/var/lib/redis/", "/var/lib/xo-server"]

ENTRYPOINT ["/xo-entry.sh"]
CMD ["/usr/bin/supervisord"]
