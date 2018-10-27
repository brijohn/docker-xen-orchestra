FROM debian:jessie

ENV DEBIAN_FRONTEND noninteractive

ARG branch=master

RUN useradd -d /app -r app && \
    useradd -r redis && \
    mkdir -p /var/lib/xo-server && \
    mkdir -p /var/lib/xoa-backups && \
    chown -R app /var/lib/xo-server && \
    chown -R app /var/lib/xoa-backups

WORKDIR /app

# Install requirements
RUN apt-get -qq update && \
    apt-get -qq install --no-install-recommends ca-certificates apt-transport-https \
    build-essential redis-server libpng-dev git python-minimal curl supervisor

# Install nodejs
RUN curl -o /usr/local/bin/n https://raw.githubusercontent.com/visionmedia/n/master/bin/n && \
    chmod +x /usr/local/bin/n && n lts

# Install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get -qq update && apt-get install yarn

# Clone code
RUN git clone https://github.com/vatesfr/xen-orchestra && \
    cd xen-orchestra && git checkout "$branch" && \
    rm -rf .git packages/xo-server/sample.config.yaml

# Build dependencies
RUN cd xen-orchestra/ && yarn && yarn run build && cd ..

# Enable all plugins
RUN cd xen-orchestra/packages/xo-server/node_modules && \
    ln -s ../../../packages/xo-server-* . && \
    cd ..

# Clean up
RUN apt-get -qq purge build-essential make gcc git libpng-dev curl && \
    apt-get autoremove -qq && apt-get clean && \
    rm -rf /usr/share/doc /usr/share/man /var/log/* /tmp/*

# Copy over entrypoint and daemon config files
COPY xo-server.yaml /app/xen-orchestra/packages/xo-server/.xo-server.yaml
COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY redis.conf /etc/redis/redis.conf
COPY xo-entry.sh /

EXPOSE 8000

VOLUME ["/var/lib/redis", "/var/lib/xo-server", "/var/lib/xoa-backups"]

ENTRYPOINT ["/xo-entry.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
