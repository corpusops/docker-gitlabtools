
DISCLAIMER - ABANDONED/UNMAINTAINED CODE / DO NOT USE
=======================================================
While this repository has been inactive for some time, this formal notice, issued on **December 10, 2024**, serves as the official declaration to clarify the situation. Consequently, this repository and all associated resources (including related projects, code, documentation, and distributed packages such as Docker images, PyPI packages, etc.) are now explicitly declared **unmaintained** and **abandoned**.

I would like to remind everyone that this project’s free license has always been based on the principle that the software is provided "AS-IS", without any warranty or expectation of liability or maintenance from the maintainer.
As such, it is used solely at the user's own risk, with no warranty or liability from the maintainer, including but not limited to any damages arising from its use.

Due to the enactment of the Cyber Resilience Act (EU Regulation 2024/2847), which significantly alters the regulatory framework, including penalties of up to €15M, combined with its demands for **unpaid** and **indefinite** liability, it has become untenable for me to continue maintaining all my Open Source Projects as a natural person.
The new regulations impose personal liability risks and create an unacceptable burden, regardless of my personal situation now or in the future, particularly when the work is done voluntarily and without compensation.

**No further technical support, updates (including security patches), or maintenance, of any kind, will be provided.**

These resources may remain online, but solely for public archiving, documentation, and educational purposes.

Users are strongly advised not to use these resources in any active or production-related projects, and to seek alternative solutions that comply with the new legal requirements (EU CRA).

**Using these resources outside of these contexts is strictly prohibited and is done at your own risk.**

Regarding the potential transfer of the project to another entity, discussions are ongoing, but no final decision has been made yet. As a last resort, if the project and its associated resources are not transferred, I may begin removing any published resources related to this project (e.g., from PyPI, Docker Hub, GitHub, etc.) starting **March 15, 2025**, especially if the CRA’s risks remain disproportionate.


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
