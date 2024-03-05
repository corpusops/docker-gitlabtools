# gitlabtools docker images
- build: ![docker.gitlabtools](https://github.com/corpusops/docker.gitlabtools/workflows/.github/workflows/cicd.yml/badge.svg?branch=master)

- Minimal Docker image combinating :
    - `corpusops/gitlabtools:{compose,latest}`: `docker/compose` & `docker:dind` images => run `compose` entrypoint
    - `corpusops/gitlabtools:docker`: `docker/compose` & `docker:latest` images => run `docker` entrypoint
    - `corpusops/gitlabtools:dind`: `docker/compose` & `docker:dind` images => run `dind` entrypoint
    - `corpusops/gitlabtools:registry2`: `docker/compose` & `docker:dind` & `registry:2`  images => run `registry2` entrypoint
    - `corpusops/gitlabtools:registrycache`: `docker/compose` & `docker:dind` & `rpardini/docker-registry-proxy`  images => run `rpardini/docker-registry-proxy` entrypoint
        - we merged https://github.com/rpardini/docker-registry-proxy/pull/78
        - we removed the VOLUME instructions as we must run through gitlab and can't control volume initializations
    - We include also [yq](https://github.com/mikefarah/yq) & [jq](https://github.com/stedolan/jq)


Warning, to run dockercompose v2, use `docker compose` explicitly as we ship both 1 & 2 versions
