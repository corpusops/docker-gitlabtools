#!/usr/bin/env bash
set -euo pipefail
if ! ( jq --version &>/dev/null; );then echo "nojq";exit 1;fi
# load ~/.docker/config.json if existing
# merge $DOCKER_AUTH_CONFIG
# export back to :
#   - ~/.docker/config.json or DOCKER_AUTH_CONFIG_FILE
#   - $DOCKER_AUTH_CONFIG (if you source the script)
# Support also those shorthand variables
# - REGISTRY_[XXX]_HOST / REGISTRY_[XXX]_USER / REGISTRY_[XXX]_PASSWORD
# - DOCKER_REGISTRY / REGISTRY_USER / REGISTRY_PASSWORD
# - DOCKERHUB_USER / DOCKERHUB_PASSWORD
export DOCKER_AUTH_CONFIG="${DOCKER_AUTH_CONFIG-}"
export DOCKER_AUTH_CONFIG_FILE="${DOCKER_AUTH_CONFIG_FILE:-"$HOME/.docker/config.json"}"
export DOCKER_AUTH_CONFIG_OUT_FILE="${DOCKER_AUTH_CONFIG_OUT_FILE-${DOCKER_AUTH_CONFIG_FILE}}"
export DOCKERHUB_PASSWORD="${DOCKERHUB_PASSWORD-}"
export DOCKERHUB_USER="${DOCKERHUB_USER-}"
export REGISTRY_USER="${REGISTRY_USER-}"
export REGISTRY_PASSWORD="${REGISTRY_PASSWORD-}"
export DOCKER_REGISTRY="${DOCKER_REGISTRY-}"
default_json="{}"
json="{}"
print_reg() { echo "{\"auths\": {\"$1\":{\"auth\":\"$(echo "$2:$3"|base64)\"}}}"; }
merge_json() { jq -rMc ". * $1"; }
write=
if [ -e "$DOCKER_AUTH_CONFIG_FILE" ];then
	json="$(cat $DOCKER_AUTH_CONFIG_FILE)"
fi
if [ "x$DOCKER_AUTH_CONFIG" != "x" ];then
	write=y
	json="$(echo "$json" | \
		merge_json "$DOCKER_AUTH_CONFIG" )"
fi
if [ "x$DOCKERHUB_PASSWORD" != "x" ] && [ "$DOCKERHUB_USER" != "x" ];then
	export REGISTRY_DOCKERHUB_HOST="https://index.docker.io/v1/"
	export REGISTRY_DOCKERHUB_USER="$DOCKERHUB_USER"
	export REGISTRY_DOCKERHUB_PASSWORD="$DOCKERHUB_PASSWORD"
fi
if [ "x$REGISTRY_USER" != "x" ] && [ "x$REGISTRY_PASSWORD" != "x" ] && [ "x$DOCKER_REGISTRY" != "x" ];then
	export REGISTRY_DOCKER_HOST="$DOCKER_REGISTRY"
	export REGISTRY_DOCKER_USER="$REGISTRY_USER"
	export REGISTRY_DOCKER_PASSWORD="$REGISTRY_PASSWORD"
fi
for envline in $(env|grep -E "^REGISTRY_([^=]+)_PASSWORD=");do
    password="$(echo $envline|sed -re "s/^(REGISTRY_.*_PASSWORD)=(.*)/\2/g")"
	variable="$(echo $envline|sed -re "s/^(REGISTRY_.*_PASSWORD)=(.*)/\1/g")"
	if [ "x${password}" != "x" ];then
		uservariable="$(echo $variable|sed -re "s/PASSWORD$/USER/g")"
		hostvariable="$(echo $variable|sed -re "s/PASSWORD$/HOST/g")"
		password_host="$(eval "echo "\${${hostvariable}}"")"
		password_user="$(eval "echo "\${${uservariable}}"")"
        if [ "x${password_user}" != "x" ] && [ "x${password_host}" != "x" ];then
            write=y
            json="$( echo "$json"|merge_json "$(print_reg "$password_host" "$password_user" "$password")" )"
        fi
	fi
done
if [ "x$write" != "x" ] && ( echo "$json"|jq &>/dev/null );then
	if [ ! -e "$(dirname "$DOCKER_AUTH_CONFIG_OUT_FILE")" ];then mkdir -p "$(dirname "$DOCKER_AUTH_CONFIG_OUT_FILE")";fi
	echo "$json" | jq > "$DOCKER_AUTH_CONFIG_OUT_FILE"
fi
# vim:set et sts=4 ts=4 tw=0:
