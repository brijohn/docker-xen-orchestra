FROM node:carbon-alpine AS buildenv

ARG branch=master

WORKDIR /app

# Install requirements
RUN apk add --no-cache -U build-base git make curl python libpng-dev

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


FROM node:carbon-alpine

RUN adduser -h /app -D -H -S app
RUN adduser -D -H -S redis

RUN mkdir -p /var/lib/xo-server
RUN mkdir -p /var/lib/xoa-backups
RUN chown -R app /var/lib/xo-server
RUN chown -R app /var/lib/xoa-backups

WORKDIR /app

RUN apk add --no-cache -U bash supervisor redis

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
