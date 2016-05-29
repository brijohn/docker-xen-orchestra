#!/bin/bash
set -e
chown app /var/lib/xo-server
exec "$@"
