# syntax=docker.io/docker/dockerfile:1
FROM --platform=linux/riscv64 ubuntu:22.04 AS builder

ARG DEBIAN_FRONTEND=noninteractive
RUN <<EOF
set -e
apt-get update
apt-get install -y --no-install-recommends \
  autoconf \
  automake \
  build-essential \
  ca-certificates \
  curl \
  libtool \
  wget
rm -rf /var/lib/apt/lists/*
EOF

COPY --from=cartesi/sdk:0.9.0 /include/linux/cartesi /include/linux/cartesi
WORKDIR /opt/cartesi/dapp
COPY . .
RUN make

FROM --platform=linux/riscv64 ubuntu:22.04

LABEL io.cartesi.rollups.sdk_name=ghcr.io/cartesi/sdk
LABEL io.cartesi.rollups.sdk_version=pr-82
LABEL io.cartesi.rollups.ram_size=128Mi

ARG DEBIAN_FRONTEND=noninteractive
RUN <<EOF
set -e
apt-get update
apt-get install -y --no-install-recommends \
  busybox-static=1:1.30.1-7ubuntu3
rm -rf /var/lib/apt/lists/* /var/log/* /var/cache/*
useradd --create-home --user-group dapp
EOF

ARG MACHINE_EMULATOR_TOOLS_VERSION=0.16.1
ADD https://github.com/cartesi/machine-emulator-tools/releases/download/v${MACHINE_EMULATOR_TOOLS_VERSION}/machine-emulator-tools-v${MACHINE_EMULATOR_TOOLS_VERSION}.deb /
RUN dpkg -i /machine-emulator-tools-v${MACHINE_EMULATOR_TOOLS_VERSION}.deb \
  && rm /machine-emulator-tools-v${MACHINE_EMULATOR_TOOLS_VERSION}.deb

ENV PATH="/opt/cartesi/bin:${PATH}"

WORKDIR /opt/cartesi/dapp
COPY --from=builder /opt/cartesi/dapp/dapp .

ENTRYPOINT ["/opt/cartesi/dapp/dapp"]
