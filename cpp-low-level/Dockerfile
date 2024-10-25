# syntax=docker.io/docker/dockerfile:1
ARG MACHINE_EMULATOR_TOOLS_VERSION=0.16.1
FROM ubuntu:22.04 AS builder

ARG DEBIAN_FRONTEND=noninteractive
RUN <<EOF
set -e
apt-get update
apt-get install -y --no-install-recommends \
  build-essential \
  libtool \
  pkg-config
rm -rf /var/lib/apt/lists/*
EOF

ARG MACHINE_EMULATOR_TOOLS_VERSION
ADD --checksum=sha256:ac93f0b8b2c8be85e1b3956f3e0206009fbb8c73f9327948a811b1864a2cee8d \
  https://github.com/cartesi/machine-emulator-tools/releases/download/v${MACHINE_EMULATOR_TOOLS_VERSION}/libcmt-dev-v${MACHINE_EMULATOR_TOOLS_VERSION}.deb \
  /tmp/libcmt-dev-v${MACHINE_EMULATOR_TOOLS_VERSION}.deb
RUN dpkg -i /tmp/libcmt-dev-v${MACHINE_EMULATOR_TOOLS_VERSION}.deb \
  && rm /tmp/libcmt-dev-v${MACHINE_EMULATOR_TOOLS_VERSION}.deb

WORKDIR /opt/cartesi/dapp
COPY . .
RUN make

FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
RUN <<EOF
set -e
apt-get update
apt-get install -y --no-install-recommends \
  busybox-static=1:1.30.1-7ubuntu3
rm -rf /var/lib/apt/lists/* /var/log/* /var/cache/*
useradd --create-home --user-group dapp
EOF

ARG MACHINE_EMULATOR_TOOLS_VERSION
ADD https://github.com/cartesi/machine-emulator-tools/releases/download/v${MACHINE_EMULATOR_TOOLS_VERSION}/libcmt-v${MACHINE_EMULATOR_TOOLS_VERSION}.deb \
  /tmp/libcmt-v${MACHINE_EMULATOR_TOOLS_VERSION}.deb
RUN dpkg -i /tmp/libcmt-v${MACHINE_EMULATOR_TOOLS_VERSION}.deb \
  && rm /tmp/libcmt-v${MACHINE_EMULATOR_TOOLS_VERSION}.deb

ADD https://github.com/cartesi/machine-emulator-tools/releases/download/v${MACHINE_EMULATOR_TOOLS_VERSION}/machine-emulator-tools-v${MACHINE_EMULATOR_TOOLS_VERSION}.deb /
RUN dpkg -i /machine-emulator-tools-v${MACHINE_EMULATOR_TOOLS_VERSION}.deb \
  && rm /machine-emulator-tools-v${MACHINE_EMULATOR_TOOLS_VERSION}.deb

ENV PATH="/opt/cartesi/bin:${PATH}"

WORKDIR /opt/cartesi/dapp
COPY --from=builder /opt/cartesi/dapp/dapp .
CMD ["/opt/cartesi/dapp/dapp"]
