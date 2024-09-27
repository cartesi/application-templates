# syntax=docker.io/docker/dockerfile:1
ARG MACHINE_EMULATOR_TOOLS_VERSION=0.16.1

# This enforces that the packages downloaded from the repositories are the same
# for the defined date, no matter when the image is built.
ARG UBUNTU_TAG=noble-20250127
ARG APT_UPDATE_SNAPSHOT=20250127T030400Z

################################################################################
# riscv64 base stage
FROM --platform=linux/riscv64 ubuntu:${UBUNTU_TAG} AS base

ARG APT_UPDATE_SNAPSHOT
ARG DEBIAN_FRONTEND=noninteractive
RUN <<EOF
set -eu
apt-get update
apt-get install -y --no-install-recommends ca-certificates curl
apt-get update --snapshot=${APT_UPDATE_SNAPSHOT}
EOF

################################################################################
# riscv64 builder stage
FROM base AS builder

ARG DEBIAN_FRONTEND=noninteractive
RUN <<EOF
set -e
apt-get install -y --no-install-recommends \
  autoconf \
  automake \
  build-essential \
  libtool \
  pkg-config
rm -rf /var/lib/apt/lists/*
EOF

ARG MACHINE_EMULATOR_TOOLS_VERSION
ADD --checksum=sha256:ac93f0b8b2c8be85e1b3956f3e0206009fbb8c73f9327948a811b1864a2cee8d \
  https://github.com/cartesi/machine-emulator-tools/releases/download/v${MACHINE_EMULATOR_TOOLS_VERSION}/libcmt-dev-v${MACHINE_EMULATOR_TOOLS_VERSION}.deb \
  /tmp/libcmt-dev-v${MACHINE_EMULATOR_TOOLS_VERSION}.deb
RUN apt-get install -y --no-install-recommends /tmp/libcmt-dev-v${MACHINE_EMULATOR_TOOLS_VERSION}.deb \
  && rm /tmp/libcmt-dev-v${MACHINE_EMULATOR_TOOLS_VERSION}.deb

WORKDIR /opt/cartesi/dapp
COPY . .
RUN make

################################################################################
# runtime stage: produces final image that will be executed
FROM base

ARG DEBIAN_FRONTEND=noninteractive
RUN <<EOF
set -e
apt-get install -y --no-install-recommends \
  busybox-static
rm -rf /var/lib/apt/lists/* /var/log/* /var/cache/*
useradd --create-home --user-group dapp
EOF

ARG MACHINE_EMULATOR_TOOLS_VERSION
ADD https://github.com/cartesi/machine-emulator-tools/releases/download/v${MACHINE_EMULATOR_TOOLS_VERSION}/libcmt-v${MACHINE_EMULATOR_TOOLS_VERSION}.deb \
  /tmp/libcmt-v${MACHINE_EMULATOR_TOOLS_VERSION}.deb
RUN apt-get install -y --no-install-recommends /tmp/libcmt-v${MACHINE_EMULATOR_TOOLS_VERSION}.deb \
  && rm /tmp/libcmt-v${MACHINE_EMULATOR_TOOLS_VERSION}.deb

ADD https://github.com/cartesi/machine-emulator-tools/releases/download/v${MACHINE_EMULATOR_TOOLS_VERSION}/machine-emulator-tools-v${MACHINE_EMULATOR_TOOLS_VERSION}.deb /
RUN apt-get install -y --no-install-recommends /machine-emulator-tools-v${MACHINE_EMULATOR_TOOLS_VERSION}.deb \
  && rm /machine-emulator-tools-v${MACHINE_EMULATOR_TOOLS_VERSION}.deb

ENV PATH="/opt/cartesi/bin:${PATH}"

WORKDIR /opt/cartesi/dapp
COPY --from=builder /opt/cartesi/dapp/dapp .
CMD ["/opt/cartesi/dapp/dapp"]
