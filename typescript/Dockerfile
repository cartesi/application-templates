# syntax=docker.io/docker/dockerfile:1

# This enforces that the packages downloaded from the repositories are the same
# for the defined date, no matter when the image is built.
ARG APT_UPDATE_SNAPSHOT=20250915T030400Z

################################################################################
# riscv64 base stage
FROM --platform=linux/riscv64 cartesi/node:22.14.0-noble-slim AS base

ARG APT_UPDATE_SNAPSHOT
ARG DEBIAN_FRONTEND=noninteractive
RUN <<EOF
set -eu
apt-get update
apt-get install -y --no-install-recommends ca-certificates curl
apt-get update --snapshot=${APT_UPDATE_SNAPSHOT}
EOF

################################################################################
# build stage: includes resources necessary for installing dependencies

# Here the image's platform does not necessarily have to be riscv64.
# If any needed dependencies rely on native binaries, you must use
# a riscv64 image such as cartesi/node:20-jammy for the build stage,
# to ensure that the appropriate binaries will be generated.
FROM --platform=$BUILDPLATFORM node:22.14.0-bookworm AS build-stage

WORKDIR /opt/cartesi/dapp

COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile
COPY . .
RUN yarn build

################################################################################
# runtime stage: produces final image that will be executed

# Here the image's platform MUST be linux/riscv64.
# Give preference to small base images, which lead to better start-up
# performance when loading the Cartesi Machine.
FROM base

ARG MACHINE_GUEST_TOOLS_VERSION=0.17.1
ARG DEBIAN_FRONTEND=noninteractive
RUN <<EOF
set -e
apt-get install -y --no-install-recommends \
  busybox-static

cd /tmp
busybox wget https://github.com/cartesi/machine-guest-tools/releases/download/v${MACHINE_GUEST_TOOLS_VERSION}/machine-guest-tools_riscv64.deb
echo "96625d97354c1cc905a8630f3d715f64b14bc5b89f3e30913d2eb02da3a01f20a7784d32c2ed340ca401dce4d1bc0e6bebfc3fbb3808725225c5793b16fa6ef4 /tmp/machine-guest-tools_riscv64.deb" \
  | sha512sum -c
apt-get install -y --no-install-recommends \
  /tmp/machine-guest-tools_riscv64.deb
rm /tmp/machine-guest-tools_riscv64.deb

# Fix non-determinism issue when installing machine-guest-tools
cp -a /etc/shadow /etc/shadow-

rm -rf /var/lib/apt/lists/* /var/log/* /var/cache/*
EOF

ENV PATH="/opt/cartesi/bin:${PATH}"

WORKDIR /opt/cartesi/dapp
COPY --from=build-stage /opt/cartesi/dapp/dist .

ENV ROLLUP_HTTP_SERVER_URL="http://127.0.0.1:5004"

ENTRYPOINT ["rollup-init"]
CMD ["node", "index.js"]
