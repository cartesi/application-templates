# syntax=docker.io/docker/dockerfile:1
FROM --platform=linux/riscv64 ubuntu:24.04 AS base

RUN apt-get update

FROM base AS builder

ARG DEBIAN_FRONTEND=noninteractive
RUN <<EOF
set -e
apt-get install -y --no-install-recommends \
  autoconf=2.71-3 \
  automake=1:1.16.5-1.3ubuntu1 \
  build-essential=12.10ubuntu1 \
  ca-certificates=20240203 \
  curl=8.5.0-2ubuntu10.3 \
  libtool=2.4.7-7build1 \
  wget=1.21.4-1ubuntu4.1
rm -rf /var/lib/apt/lists/*
EOF

COPY --from=cartesi/sdk:0.9.0 /include/linux/cartesi /include/linux/cartesi
WORKDIR /opt/cartesi/dapp
COPY . .
RUN make

FROM base

ARG MACHINE_EMULATOR_TOOLS_VERSION=0.14.1
ADD https://github.com/cartesi/machine-emulator-tools/releases/download/v${MACHINE_EMULATOR_TOOLS_VERSION}/machine-emulator-tools-v${MACHINE_EMULATOR_TOOLS_VERSION}.deb /
RUN dpkg -i /machine-emulator-tools-v${MACHINE_EMULATOR_TOOLS_VERSION}.deb \
  && rm /machine-emulator-tools-v${MACHINE_EMULATOR_TOOLS_VERSION}.deb

LABEL io.cartesi.rollups.sdk_version=0.9.0
LABEL io.cartesi.rollups.ram_size=128Mi

ARG DEBIAN_FRONTEND=noninteractive
RUN <<EOF
set -e
apt-get install -y --no-install-recommends \
  busybox-static=1:1.36.1-6ubuntu3.1
rm -rf /var/lib/apt/lists/* /var/log/* /var/cache/*
useradd --create-home --user-group dapp
EOF

ENV PATH="/opt/cartesi/bin:${PATH}"

WORKDIR /opt/cartesi/dapp
COPY --from=builder /opt/cartesi/dapp/dapp .

ENTRYPOINT ["/opt/cartesi/dapp/dapp"]
