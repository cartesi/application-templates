# syntax=docker.io/docker/dockerfile:1
ARG MACHINE_GUEST_TOOLS_VERSION=0.17.1

# This enforces that the packages downloaded from the repositories are the same
# for the defined date, no matter when the image is built.
ARG UBUNTU_TAG=noble-20251001
ARG APT_UPDATE_SNAPSHOT=20251009T030400Z

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
  busybox-static \
  libtool \
  pkg-config
rm -rf /var/lib/apt/lists/*
EOF

ARG MACHINE_GUEST_TOOLS_VERSION
ADD https://github.com/cartesi/machine-guest-tools/releases/download/v${MACHINE_GUEST_TOOLS_VERSION}/machine-guest-tools_riscv64.deb  /tmp/machine-guest-tools_riscv64.deb

RUN <<EOF
set -e
echo "96625d97354c1cc905a8630f3d715f64b14bc5b89f3e30913d2eb02da3a01f20a7784d32c2ed340ca401dce4d1bc0e6bebfc3fbb3808725225c5793b16fa6ef4 /tmp/machine-guest-tools_riscv64.deb" \
  | sha512sum -c
apt-get install -y --no-install-recommends \
  /tmp/machine-guest-tools_riscv64.deb
rm /tmp/machine-guest-tools_riscv64.deb
EOF

WORKDIR /opt/cartesi/dapp
COPY . .
RUN make

################################################################################
# runtime stage: produces final image that will be executed
FROM base

ARG MACHINE_GUEST_TOOLS_VERSION
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
COPY --from=builder /opt/cartesi/dapp/dapp .
CMD ["/opt/cartesi/dapp/dapp"]
