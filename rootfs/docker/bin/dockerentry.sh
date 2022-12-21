#!/usr/bin/env bash
set -euo pipefail
if [ "x${SDEBUG-}" = "x1" ];then set -x;fi
. /bin/cicdtools.sh
docker-credential-copsgitlab init
exec docker-entrypoint.sh "$@"
# vim:set et sts=4 ts=4 tw=0:
