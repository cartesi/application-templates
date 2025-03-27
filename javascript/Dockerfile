# syntax=docker.io/docker/dockerfile:1

# build stage: includes resources necessary for installing dependencies

# Here the image's platform does not necessarily have to be riscv64.
# If any needed dependencies rely on native binaries, you must use
# a riscv64 image such as cartesi/node:20-jammy for the build stage,
# to ensure that the appropriate binaries will be generated.
FROM --platform=$BUILDPLATFORM node:20.16.0-bookworm AS build-stage

WORKDIR /opt/cartesi/dapp
COPY . .
RUN yarn install && yarn build

# runtime stage: produces final image that will be executed

# Here the image's platform MUST be linux/riscv64.
# Give preference to small base images, which lead to better start-up
# performance when loading the Cartesi Machine.
FROM cartesi/node:20.16.0-jammy-slim

ARG DEBIAN_FRONTEND=noninteractive
RUN <<EOF
set -e
apt-get update
apt-get install -y --no-install-recommends \
  busybox-static=1:1.30.1-7ubuntu3
rm -rf /var/lib/apt/lists/* /var/log/* /var/cache/*
useradd --create-home --user-group dapp
EOF

ARG MACHINE_GUEST_TOOLS_VERSION=0.17.0-test3
ADD https://github.com/cartesi/machine-guest-tools/releases/download/v${MACHINE_GUEST_TOOLS_VERSION}/machine-guest-tools_riscv64.tar.gz  /tmp/machine-guest-tools_riscv64.tar.gz

RUN <<EOF
set -e
echo "944cb99a021fe94291bbd2682c22cae7be51bc5dc9120f720890ec420dd488f1f92a7fba26d3cc48037f212126de8042e41d3d6bda2c6df0b5d3cc43fe1eb27a /tmp/machine-guest-tools_riscv64.tar.gz" \
  | sha512sum -c
tar -C / -xzf /tmp/machine-guest-tools_riscv64.tar.gz
rm /tmp/machine-guest-tools_riscv64.tar.gz
EOF

ENV PATH="/opt/cartesi/bin:${PATH}"

WORKDIR /opt/cartesi/dapp
COPY --from=build-stage /opt/cartesi/dapp/dist .

ENV ROLLUP_HTTP_SERVER_URL="http://127.0.0.1:5004"

ENTRYPOINT ["rollup-init"]
CMD ["node", "index.js"]
