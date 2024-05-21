#!/usr/bin/env bash
set -euo pipefail
if [ "x${SDEBUG-}" = "x1" ];then set -x;fi
. /bin/cicdtools.sh
docker-auth.sh
exec /usr/local/bin/docker-compose-entrypoint.sh "$@"
# vim:set et sts=4 ts=4 tw=0:
