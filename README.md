# dockerandcompose docker images
- build: ![docker.dockerandcompose](https://github.com/corpusops/docker.dockerandcompose/workflows/.github/workflows/cicd.yml/badge.svg?branch=master)

- Minimal Docker image combinating :
    - `corpusops/dockerandcompose:{compose,latest}`: `docker/compose` & `docker:dind` images => run compose entrypoint
    - `corpusops/dockerandcompose:docker`: `docker/compose` & `docker:latest` images => run docker entrypoint
    - `corpusops/dockerandcompose:dind`: `docker/compose` & `docker:dind` images => run dind entrypoint
    - `corpusops/dockerandcompose:registry2`: `docker/compose` & `docker:dind` & `registry:2`  images => run registry2 entrypoint
    - We include also [yq](https://github.com/mikefarah/yq) & [jq](https://github.com/stedolan/jq)


Warning, to run dockercompose v2, use `docker compose` explicitly as we ship both 1 & 2 versions
