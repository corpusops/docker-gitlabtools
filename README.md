# gitlabtools docker images
- build: ![docker.gitlabtools](https://github.com/corpusops/docker-gitlabtools/workflows/.github/workflows/cicd.yml/badge.svg?branch=main)

- Minimal Docker image combinating :
    - `corpusops/gitlabtools:{compose,latest}`: `docker/compose` & `docker:dind` images => run `compose` entrypoint
    - `corpusops/gitlabtools:docker`: `docker/compose` & `docker:latest` images => run `docker` entrypoint
    - `corpusops/gitlabtools:dind`: `docker/compose` & `docker:dind` images => run `dind` entrypoint
    - `corpusops/gitlabtools:registry2`: `docker/compose` & `docker:dind` & `registry:2`  images => run `registry2` entrypoint
    - `corpusops/gitlabtools:registrycache`: `docker/compose` & `docker:dind` & `rpardini/docker-registry-proxy`  images => run `rpardini/docker-registry-proxy` entrypoint
        - we merged https://github.com/rpardini/docker-registry-proxy/pull/78
        - we removed the VOLUME instructions as we must run through gitlab and can't control volume initializations
        - we added sensible entrypoints defaults (allow own auth & push by default, and increase all timeouts).
        - we modified certs validity to be extreme.
        - we added a way to use another directory not mounted as a volume for storing cache, etc, as the container creation is controlled in our context by gitlab and we cant specify it as a volume. You can then use `REGISTRIES_CACHE_DIR` as a TOP directory to store the registry cache data.
        - For more details or spot which variable to override, see [rootfs/registryproxy/bin/dockerentry.sh](https://github.com/corpusops/docker-gitlabtools/blob/main/rootfs/registryproxy/bin/dockerentry.sh) and the [original documentation](https://github.com/rpardini/docker-registry-proxy)
    - We include also [yq](https://github.com/mikefarah/yq) & [jq](https://github.com/stedolan/jq)
- Those images are responsible to setup adequate services in context of gitlab, eg:
    - make services available ASAP (dummy servers)
    - make docker login easier thorough:
        - `DOCKER_AUTH_CONFIG`
        - `DOCKERHUB_USER/DOCKERHUB_PASSWORD`
        - `DOCKER_REGISTRY/REGISTRY_USER/REGISTRY_PASSWORD`

Warning, to run dockercompose v2, use `docker compose` explicitly as we ship both 1 & 2 versions
