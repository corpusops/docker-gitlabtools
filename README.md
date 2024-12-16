# gitlabtools docker images

DISCLAIMER
============

**UNMAINTAINED/ABANDONED CODE / DO NOT USE**

Due to the new EU Cyber Resilience Act (as European Union), even if it was implied because there was no more activity, this repository is now explicitly declared unmaintained.

The content does not meet the new regulatory requirements and therefore cannot be deployed or distributed, especially in a European context.

This repository now remains online ONLY for public archiving, documentation and education purposes and we ask everyone to respect this.

As stated, the maintainers stopped development and therefore all support some time ago, and make this declaration on December 15, 2024.

We may also unpublish soon (as in the following monthes) any published ressources tied to the corpusops project (pypi, dockerhub, ansible-galaxy, the repositories).
So, please don't rely on it after March 15, 2025 and adapt whatever project which used this code.



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
