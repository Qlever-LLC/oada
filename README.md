# OADA DooD Image

[![Test](https://github.com/Qlever-LLC/oada/actions/workflows/build-and-test.yml/badge.svg)](https://github.com/Qlever-LLC/oada/actions/workflows/build-and-test.yml)
[![License](https://img.shields.io/github/license/Qlever-LLC/oada)](LICENSE)
[![Docker Pulls](https://img.shields.io/docker/pulls/qlever/oada)][dockerhub]

A "single image" (using DooD) version of the [OADA reference API server].

This is only meant for testing and development purposes,
**DO NOT USE THIS IN PRODUCTION**.

## Usage

This image can be used to boostrap an OADA instance on your local machine.
The only requirement is [Docker].

```shell
# Must volume mount docker socket for DooD
# $PORT is the host port to bind for OADA HTTP
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -p $PORT:80 \
  ghcr.io/qlever-llc/oada
```

### GitHub Actions

The image can also be used to deploy an oada [service] in GitHub Actions.

```yaml
services:
  oada:
    image: ghcr.io/qlever-llc/oada
    # API exposes HTTP on port 80
    ports:
      - 80
    # Needed for DooD
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock"
```

You can then access OADA at its randomly assigned host port with

`http://localhost:${{ job.services.oada.ports['80'] }}`

or at `http://oada` from inside a container.

[Docker]: https://www.docker.com
[dockerhub]: https://hub.docker.com/repository/docker/qlever/oada
[service]: https://docs.github.com/en/actions/using-containerized-services/about-service-containers
[OADA reference API server]: https://github.com/OADA/server
