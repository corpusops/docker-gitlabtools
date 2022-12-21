#!/usr/bin/env bash
set -euo pipefail
if [ "x${SDEBUG-}" = "x1" ];then set -x;fi
. /bin/cicdtools.sh
docker-credential-copsgitlab init
cd /
# registry cache settings
# allow to use either a custom top directory or custom separate directories for cacert, certs, & cache directories
# as the image has hardcoded the location, we cant always map volumes at the right place...
export REGISTRIES_CACHE_CERTS_DIR="${REGISTRIES_CACHE_CERTS_DIR-}"
export REGISTRIES_CACHE_CA_DIR="${REGISTRIES_CACHE_CA_DIR-}"
export REGISTRIES_CACHE_CACHE_DIR="${REGISTRIES_CACHE_CACHE_DIR-}"
export REGISTRIES_CACHE_DIR="${REGISTRIES_CACHE_DIR-}"
if [[ -n "$REGISTRIES_CACHE_DIR" ]];then
    export REGISTRIES_CACHE_CERTS_DIR="${REGISTRIES_CACHE_CERTS_DIR:-"$REGISTRIES_CACHE_DIR/certs"}"
    export REGISTRIES_CACHE_CA_DIR="${REGISTRIES_CACHE_CA_DIR:-"$REGISTRIES_CACHE_DIR/ca"}"
    export REGISTRIES_CACHE_CACHE_DIR="${REGISTRIES_CACHE_CACHE_DIR:-"$REGISTRIES_CACHE_DIR/cache"}"
fi
export CI_COMMON_REGISTRIES="${CI_COMMON_REGISTRIES:-k8s.gcr.io gcr.io quay.io gitlab.com registry.gitlab.com}"
if [[ -n "${DOCKER_REGISTRY-}" ]];then export REGISTRIES="${CI_REGISTRIES:-${CI_COMMON_REGISTRIES} $DOCKER_REGISTRY}";fi
export REGISTRIES_CACHE_HOSTNAME="${REGISTRIES_CACHE_HOSTNAME:-registriescache}"
export REGISTRIES="${REGISTRIES_CACHE_HOSTNAME} $(eval echo $REGISTRIES)"
export PROXY_REQUEST_BUFFERING="${CI_PROXY_REQUEST_BUFFERING:-false}"
export ALLOW_PUSH="${CI_ALLOW_PUSH:-true}"
export ALLOW_OWN_AUTH="${CI_ALLOW_OWN_AUTH:-true}"
export ALLOW_PUSH_WITH_OWN_AUTH="${CI_ALLOW_PUSH_WITH_OWN_AUTH:-true}"
# ALLOW_PUSH_WITH_OWN_AUTH superseeds ALLOW_OWN_AUTH
if [ "x$ALLOW_PUSH_WITH_OWN_AUTH" = "xtrue" ];then export ALLOW_PUSH="false";fi
export ENABLE_MANIFEST_CACHE="${CI_ENABLE_MANIFEST_CACHE:-false}"
export SEND_TIMEOUT="${CI_SEND_TIMEOUT:-3600s}"
export CLIENT_BODY_TIMEOUT="${CI_CLIENT_BODY_TIMEOUT:-3600s}"
export CLIENT_HEADER_TIMEOUT="${CI_CLIENT_HEADER_TIMEOUT:-3600s}"
export PROXY_READ_TIMEOUT="${CI_PROXY_READ_TIMEOUT:-3600s}"
export PROXY_CONNECT_TIMEOUT="${CI_PROXY_CONNECT_TIMEOUT:-3600s}"
export PROXY_SEND_TIMEOUT="${CI_PROXY_SEND_TIMEOUT:-3600s}"
export PROXY_CONNECT_READ_TIMEOUT="${CI_PROXY_CONNECT_READ_TIMEOUT:-3600s}"
export PROXY_CONNECT_CONNECT_TIMEOUT="${CI_PROXY_CONNECT_CONNECT_TIMEOUT:-3600s}"
export PROXY_CONNECT_SEND_TIMEOUT="${CI_PROXY_CONNECT_SEND_TIMEOUT:-3600s}"
export KEEPALIVE_TIMEOUT="${CI_KEEPALIVE_TIMEOUT:-900s}"
# block for inside gitlab-ci cookiecutters projects use; wait for the registry cache to be fully setup
linkdir() { ( rm -rf "$1" || true ) && create_dirs "$2" && ln -sfv "$2" "$1"; }
if [[ -n "$REGISTRIES_CACHE_CERTS_DIR" ]] && [[ "$REGISTRIES_CACHE_CERTS_DIR" != "/certs"               ]];then linkdir /certs                "${REGISTRIES_CACHE_CERTS_DIR}";fi
if [[ -n "$REGISTRIES_CACHE_CA_DIR"    ]] && [[ "$REGISTRIES_CACHE_CA_DIR" != "/ca"                     ]];then linkdir /ca                   "${REGISTRIES_CACHE_CA_DIR}";fi
if [[ -n "$REGISTRIES_CACHE_CACHE_DIR" ]] && [[ "$REGISTRIES_CACHE_CACHE_DIR" != "/docker_mirror_cache" ]];then linkdir /docker_mirror_cache  "${REGISTRIES_CACHE_CACHE_DIR}";fi
sed -i -re "s/-days \d+/-days 36500/g" /*.sh
# let gitlab not wait for service launch and mimic a service running on exposed ports
if [ "x${COMMON_HOSTS_FILE-}" != "x" ];then make_dummy_server 5000 443 80 8081 8082 3128 && refresh_gitlab_services;fi
if (getent passwd nginx &>/dev/null);then while read f;do chown -v nginx "$f";done < <(find /docker_mirror_cache/ -not -type l -a -not -user nginx);fi
DEFAULT_EP='nginx -g "daemon off;"'
if [ "x${COMMON_HOSTS_FILE-}" != "x" ];then stop_dummy_servers;fi
. /entrypoint.sh "${@:-$DEFAULT_EP}"
# vim:set et sts=4 ts=4 tw=0:
