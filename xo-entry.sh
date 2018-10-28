#!/bin/bash
set -e
chown -R redis /var/lib/redis
chown app /var/lib/xo-server
exec "$@"
