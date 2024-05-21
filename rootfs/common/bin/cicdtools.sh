#!/usr/bin/env bash
log() { echo "$@">&2; }
die() { log "$@";exit 1; }
vv() { log "$@";"$@"; }
create_dirs() { for i in $@;do if [ ! -e "$i" ];then mkdir -pv "${i}";fi;done; }
uniquify() { echo $@|xargs -n1|awk '!seen[$0]++'; }
retry_cmd() { retries=${retries:-10};sleep=${sleep:-1};i=0;until ( "$@" );do i=$(($i+1));test $i -gt ${retries} && return 1;sleep ${sleep};done;return 0; }
add_cacrt() {
 if [ "x${@-${CA_CERTIFICATES_PATHS-}${CA_CERTIFICATES_PATH-}}" = "x" ];then return 0;fi
 if (apk --version >/dev/null 2>&1);then apk add ca-certificates;fi
 if (apt-get --version >/dev/null 2>&1);then apt-get install -y ca-certificates;fi
 todo="" && for capath in ${@-${CA_CERTIFICATES_PATHS-} ${CA_CERTIFICATES_PATH-}};do
   if [ -e "${capath}" ];then log "Add custom CACERT: $capath" && cp -f "${capath}" /usr/local/share/ca-certificates && todo=1;fi
 done && if [ "x$todo" != "x" ];then
   aln="" && if [ -e /etc/ssl/cert.pem ];then aln=1;rm /etc/ssl/cert.pem;fi # fix alpine bug
   update-ca-certificates --fresh
   if [ "x$aln" != "x" ];then ln -s /etc/ssl/certs/ca-certificates.crt /etc/ssl/cert.pem;fi
 fi
}
make_dummy_server() { touch /tmp/dummyready;for i in $@;do (while [ -e /tmp/dummyready ];do printf "HTTP/1.1 200 OK\nContent-Length: 8\n\nstarted"|nc -l -p $i;done;)&done;echo $@|xargs -n1>>/tmp/dummyservers; }
stop_dummy_servers() { rm /tmp/dummyready && for i in $(cat /tmp/dummyservers|xargs -n1|uniq);do (wget --spider 127.0.0.1:$i||true);done; }
download_registriescache_cacert() {
 wget registriescache:3128/ca.crt -O /tmp/registriescache.crt
 if [ "x$(cat /tmp/registriescache.crt|wc -l)" = "x0" ];then rm /tmp/registriescache.crt;fi
 test -e /tmp/registriescache.crt
}
add_registriescache_cacrt() {
 t=${REGISTRIESCACHE_TIMEOUT:-240} vwait_ready download_registriescache_cacert
 add_cacrt /tmp/registriescache.crt
}
refresh_gitlab_services() {
    until [ -e "${COMMON_HOSTS_FILE}" ];do sleep 0.1;done
    cp /etc/hosts /etc/hosts.c;for i in $(awk '{$1=""}1' "${COMMON_HOSTS_FILE}"|xargs -n1);do sed -i -re "/\s$i(\s|$)/d" /etc/hosts.c;done;cat /etc/hosts.c "${COMMON_HOSTS_FILE}">/etc/hosts;
    cat /etc/hosts
}
docker_login() {
 if [ "x${DOCKERHUB_PASSWORD-}" != "x" ];then
  echo "login to DockerHub" >&2
  echo "${DOCKERHUB_PASSWORD}" | docker login --username="${DOCKERHUB_USER}" --password-stdin
 fi
 if [ "x${REGISTRY_PASSWORD}" != "x" ];then
  echo "login to $DOCKER_REGISTRY" >&2
  echo "$REGISTRY_PASSWORD" | docker login "$DOCKER_REGISTRY" --username="$REGISTRY_USER" --password-stdin
 fi
}
wait_docker() { docker system info >/dev/null 2>&1; }
wait_registriescache() { ( set -e;printf "test"|nc -w 2 registriescache 3128; ) }
wait_ready() { s="${s:-0.5}";t="${t:-800}";start=$(date +%s);until ("$@";);do
 d=$(date +%s);dt=$((${d}-${start}));if [ ${dt} -gt ${t} ];then echo "  no more retries: $@" >&2;return 1;fi
 if [ $(( ${dt} % ${CI_OPEN_MSG_DELAY:-240} )) -eq 0 ];then echo "  CI keeps open" >&2;fi
 (cat /dev/zero|read -t ${s}||exit 0);done; }
vwait_ready() { vv wait_ready "$@"; }
# vim:set et sts=4 ts=4 tw=0:
