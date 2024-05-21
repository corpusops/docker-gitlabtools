#!/usr/bin/env bash
set -ex
cd $(dirname $(readlink -f "$0"))
W=$(pwd)
t=$W/Dockerfile.registryproxy
if [ ! -e docker-registry-proxy/Dockerfile ];then
    git submodule init
    git submodule update
fi
cd docker-registry-proxy
git remote add upstream https://github.com/rpardini/docker-registry-proxy.git || true
git remote add corpusops https://github.com/corpusops/docker-registry-proxy.git || true
git fetch --all
git reset --hard corpusops/ownauth
egrep "^ARG BASE"  Dockerfile > "$t"
cat ../Dockerfile.registryproxy.pre >> "$t"
egrep -v "^(ARG BASE|VOLUME )"  Dockerfile |sed -re "s/ADD /ADD docker-registry-proxy\//g">> "$t"
sed -i -re "/^mkdir.*certs/d" create*sh
cat ../Dockerfile.registryproxy.post >> "$t"
# vim:set et sts=4 ts=4 tw=0:
