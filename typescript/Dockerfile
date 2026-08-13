# syntax=docker.io/docker/dockerfile:1

# This enforces that the packages downloaded from the repositories are the same
# for the defined date, no matter when the image is built.
ARG APT_UPDATE_SNAPSHOT=20260801T030400Z
ARG MACHINE_GUEST_TOOLS_VERSION=0.18.0
ARG MACHINE_GUEST_TOOLS_SHA256SUM=204d4260defd68e11b957ae1f1b511b6c2c74345c918748be06f592733b72dcd

################################################################################
# riscv64 base stage
FROM --platform=linux/riscv64 cartesi/node:22.14.0-noble-slim AS base

ARG APT_UPDATE_SNAPSHOT
ARG DEBIAN_FRONTEND=noninteractive
RUN <<EOF
set -eu
apt-get update
apt-get install -y --no-install-recommends ca-certificates
apt-get update --snapshot=${APT_UPDATE_SNAPSHOT}
EOF

################################################################################
# dependencies stage: installs the dependencies needed at runtime

# Here the image's platform MUST be linux/riscv64, because @cartesi/rollup is a
# native addon: the installation selects the prebuilt binary of the platform it
# runs on. Only production dependencies are installed, the ones used to build
# the application are installed in the build stage below.
FROM base AS deps-stage

WORKDIR /opt/cartesi/dapp
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
RUN corepack enable pnpm && pnpm install --frozen-lockfile --prod

################################################################################
# build stage: includes resources necessary for building the application

# Here the image's platform does not necessarily have to be riscv64, because
# the application code is bundled without its dependencies, which are installed
# by the stage above.
FROM --platform=$BUILDPLATFORM node:22.14.0-bookworm AS build-stage

WORKDIR /opt/cartesi/dapp

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
RUN corepack enable pnpm && pnpm install --frozen-lockfile
COPY . .
RUN pnpm build

################################################################################
# runtime stage: produces final image that will be executed

# Here the image's platform MUST be linux/riscv64.
# Give preference to small base images, which lead to better start-up
# performance when loading the Cartesi Machine.
FROM base

ARG MACHINE_GUEST_TOOLS_VERSION
ARG MACHINE_GUEST_TOOLS_SHA256SUM
ADD --checksum=sha256:${MACHINE_GUEST_TOOLS_SHA256SUM} \
  https://github.com/cartesi/machine-guest-tools/releases/download/v${MACHINE_GUEST_TOOLS_VERSION}/machine-guest-tools_riscv64.deb \
  /tmp/machine-guest-tools_riscv64.deb

ARG APT_UPDATE_SNAPSHOT
ARG DEBIAN_FRONTEND=noninteractive
RUN <<EOF
set -eu
apt-get install -y --no-install-recommends --snapshot=${APT_UPDATE_SNAPSHOT} \
  busybox-static \
  /tmp/machine-guest-tools_riscv64.deb

apt-get remove -y --purge ca-certificates
apt-get autoremove -y --purge

rm /tmp/machine-guest-tools_riscv64.deb
rm -rf /var/lib/apt/lists/* /var/log/* /var/cache/*
EOF

ENV PATH="/opt/cartesi/bin:${PATH}"

WORKDIR /opt/cartesi/dapp
COPY --from=deps-stage /opt/cartesi/dapp/node_modules ./node_modules
COPY --from=build-stage /opt/cartesi/dapp/dist .

ENTRYPOINT ["node"]
CMD ["index.mjs"]
