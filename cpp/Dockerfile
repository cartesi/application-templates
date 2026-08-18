# syntax=docker.io/docker/dockerfile:1

# This enforces that the packages downloaded from the repositories are the same
# for the defined date, no matter when the image is built.
ARG UBUNTU_TAG=noble-20260810
ARG APT_UPDATE_SNAPSHOT=20260818T030400Z
ARG MACHINE_GUEST_TOOLS_VERSION=0.18.0
ARG MACHINE_GUEST_TOOLS_SHA256SUM=204d4260defd68e11b957ae1f1b511b6c2c74345c918748be06f592733b72dcd

################################################################################
# riscv64 base stage
FROM --platform=linux/riscv64 ubuntu:${UBUNTU_TAG} AS base

ARG APT_UPDATE_SNAPSHOT
ARG DEBIAN_FRONTEND=noninteractive
RUN <<EOF
set -eu
apt-get update
apt-get install -y --no-install-recommends ca-certificates
apt-get update --snapshot=${APT_UPDATE_SNAPSHOT}
EOF

################################################################################
# riscv64 builder stage
FROM base AS builder

ARG APT_UPDATE_SNAPSHOT
ARG DEBIAN_FRONTEND=noninteractive
RUN <<EOF
set -eu
apt-get install -y --no-install-recommends --snapshot=${APT_UPDATE_SNAPSHOT} \
  autoconf \
  automake \
  build-essential \
  ca-certificates \
  curl \
  libtool
rm -rf /var/lib/apt/lists/*
EOF

WORKDIR /opt/cartesi/dapp
COPY . .
RUN make

################################################################################
# runtime stage: produces final image that will be executed
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
COPY --from=builder /opt/cartesi/dapp/dapp .

ENV ROLLUP_HTTP_SERVER_URL="http://127.0.0.1:5004"

ENTRYPOINT ["rollup-init"]
CMD ["/opt/cartesi/dapp/dapp"]
