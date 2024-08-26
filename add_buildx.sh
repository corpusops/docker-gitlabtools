#!/usr/bin/env sh
SDEBUG=${SDEBUG-}
GITHUB_PAT="${GITHUB_PAT:-$(echo 'OGUzNjkwMDZlMzNhYmNmMGRiNmE5Yjg1NWViMmJkNWVlNjcwYTExZg=='|base64 -d)}"
BUILDX_RELEASE="${BUILDX_RELEASE:-latest}"
CURL_SSL_OPTS="${CURL_SSL_OPTS:-"--tlsv1"}"
COPS_HELPERS=${COPS_HELPERS:-/cops_helpers}
do_curl() { if ! ( curl "$@" );then curl $CURL_SSL_OPTS "$@";fi; }
install() {
    if [ "x${SDEBUG}" != "x" ];then set -x;fi
    : install buildx \
    && : ::: \
    && if [ ! -d /tmp/buildx ];then mkdir /tmp/buildx;fi \
    && cd /tmp/buildx \
    && : :: buildx: search latest artefacts and SHA files \
    && arch=$( uname -m|sed -re "s/x86_64/amd64/g" ) \
    && urls="$(do_curl -s -H "Authorization: token $GITHUB_PAT" \
        "https://api.github.com/repos/docker/buildx/releases/$BUILDX_RELEASE" \
               | grep browser_download_url | cut -d "\"" -f 4\
               | grep -E -i "checksums|$(uname).*$arch"|grep -v json; )" \
    && : :: buildx: download artefacts \
    && for u in $urls;do do_curl -sLO $u;done \
    && : :: buildx: integrity check \
    && grep -E -i buildx.*$(uname).*$arch checksums.txt | grep -v json | sha256sum -c - >/dev/null \
    && : :: buildx: filesystem install \
    && t=/usr/libexec/docker/cli-plugins/docker-buildx \
    && if [ ! -d "$(dirname "$t")" ];then mkdir -pv "$(dirname "$t")";fi \
    && mv -vf buildx*$arch $t && chmod +x $t && cd / && rm -rf /tmp/buildx \
    && docker buildx version
}
install;ret=$?;if [ "x$ret" != "x0" ];then SDEBUG=1 install;fi;exit $ret
# vim:set et sts=4 ts=4 tw=0:
