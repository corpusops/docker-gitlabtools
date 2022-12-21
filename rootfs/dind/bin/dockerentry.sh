#!/usr/bin/env bash
set -euo pipefail
if [ "x${SDEBUG-}" = "x1" ];then set -x;fi
. /bin/cicdtools.sh
# let gitlab not wait for service launch and mimic a service running on exposed ports
docker-credential-copsgitlab init
# block for inside gitlab-ci cookiecutters projects use; wait for the registry cache to be fully setup
if [ "x${COMMON_HOSTS_FILE-}" != "x" ];then
    # let gitlab not wait for service launch and mimic a service running on exposed ports
    make_dummy_server 2375 2376
    refresh_gitlab_services
    add_cacrt
    add_registriescache_cacrt
    stop_dummy_servers
fi
exec dockerd-entrypoint.sh --experimental "$@"
# vim:set et sts=4 ts=4 tw=0:
