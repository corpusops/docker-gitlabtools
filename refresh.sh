#!/usr/bin/env bash
set -ex
cd $(dirname $(readlink -f "$0"))
W=$(pwd)
t=$W/Dockerfile.registryproxy
git submodule init
git submodule update
cd docker-registry-proxy
git fetch --all
git pull origin master
git reset --hard
egrep "^ARG BASE"  Dockerfile > "$t"
cat ../Dockerfile.registryproxy.pre >> "$t"
egrep -v "^(ARG BASE|VOLUME )"  Dockerfile |sed -re "s/ADD /ADD docker-registry-proxy\//g">> "$t"
sed -i -re "/mkdir.*certs/d" create*sh
cat ../Dockerfile.registryproxy.post >> "$t"
# vim:set et sts=4 ts=4 tw=80:
