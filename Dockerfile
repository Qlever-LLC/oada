# Copyright 2022 Qlever LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ARG DOCKER_VER=cli
ARG OADA_VER=3.10.0

# Fetch the oada compose file
FROM docker:$DOCKER_VER AS oada-compose
ARG OADA_VER

RUN if test "${OADA_VER}" = 'latest'; then \
    wget https://github.com/OADA/server/releases/latest/download/docker-compose.yml; \
    else \
    wget https://github.com/OADA/server/releases/download/v${OADA_VER}/docker-compose.yml; \
    fi

FROM docker:$DOCKER_VER

WORKDIR /qlever-oada

COPY --from=oada-compose docker-compose.yml /qlever-oada/

ENV DOMAIN=oada.local
COPY ./docker-compose.override.yml /qlever-oada/

RUN apk add --no-cache \
    curl \
    dumb-init \
    socat

COPY ./entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/usr/bin/dumb-init", "--rewrite", "15:2", "--", "/entrypoint.sh"]
CMD ["up", "--no-log-prefix"]

# Wait for /bookmarks to be up
HEALTHCHECK --start-period=4m --interval=5s --retries=50 CMD \
    curl \
    --fail \
    -H "Authorization: Bearer god" \
    "http://localhost/bookmarks" \
    || exit 1

EXPOSE 80

# Use development mode
ENV NODE_ENV=development
ENV REDPANDA_MODE=development

# Load default resources/users/etc.
ENV arangodb__ensureDefaults=true

# Use our auth server for OIDC
ENV OIDC_ISSUER=http://auth/oadaauth/.well-known/oada-configuration

ARG OADA_VER
ENV OADA_VERSION=${OADA_VER}

