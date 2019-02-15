FROM node:carbon-stretch-slim AS buildenv

ENV DEBIAN_FRONTEND noninteractive

ARG branch=master

RUN useradd -d /app -r app

WORKDIR /app

# Install requirements
RUN apt-get -qq update && \
    apt-get -qq install --no-install-recommends ca-certificates apt-transport-https \
    build-essential libpng-dev git python

# Clone code
RUN git clone https://github.com/vatesfr/xen-orchestra

WORKDIR /app/xen-orchestra

RUN git checkout "$branch"
RUN rm -rf .git packages/xo-server/sample.config.yaml

# Build dependencies
RUN yarn
RUN yarn run build

WORKDIR /app/xen-orchestra/packages/xo-server/node_modules

# Enable all plugins
RUN ln -s ../../../packages/xo-server-* .


FROM node:carbon-stretch-slim

RUN useradd -d /app -r app
RUN useradd -r redis

RUN mkdir -p /var/lib/xo-server
RUN mkdir -p /var/lib/xoa-backups
RUN chown -R app /var/lib/xo-server
RUN chown -R app /var/lib/xoa-backups

WORKDIR /app

RUN apt-get -qq update && \
    apt-get -qq install --no-install-recommends ca-certificates redis-server supervisor

# Copy built code
COPY --from=buildenv /app/xen-orchestra /app/xen-orchestra

# Copy over entrypoint and daemon config files
COPY xo-server.yaml /app/xen-orchestra/packages/xo-server/.xo-server.yaml
COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY redis.conf /etc/redis/redis.conf
COPY xo-entry.sh /

EXPOSE 8000

VOLUME ["/var/lib/redis", "/var/lib/xo-server", "/var/lib/xoa-backups"]

ENTRYPOINT ["/xo-entry.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
