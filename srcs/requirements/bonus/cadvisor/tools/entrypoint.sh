#!/bin/sh

set -eu

exec /usr/local/bin/cadvisor \
	--port=8080 \
	--url_base_prefix=/cadvisor
