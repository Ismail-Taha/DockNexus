#!/bin/sh
set -eu

/usr/local/bin/generate-certs.sh

exec nginx -g 'daemon off;'
