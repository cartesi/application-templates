# syntax=docker.io/docker/dockerfile:1

# This enforces that the packages downloaded from the repositories are the same
# for the defined date, no matter when the image is built.
ARG UBUNTU_TAG=noble-20260610
ARG APT_UPDATE_SNAPSHOT=20260701T030400Z
ARG MACHINE_GUEST_TOOLS_VERSION=0.17.2
ARG MACHINE_GUEST_TOOLS_SHA256SUM=c077573dbcf0cdc146adf14b480bfe454ca63aa4d3e8408c5487f550a5b77a41
ARG GOVERSION=1.25.3

################################################################################
# riscv64 base stage
FROM --platform=linux/riscv64 ubuntu:${UBUNTU_TAG} AS base-riscv64

ARG APT_UPDATE_SNAPSHOT
ARG DEBIAN_FRONTEND=noninteractive
RUN <<EOF
set -eu
apt-get update
apt-get install -y --no-install-recommends ca-certificates
apt-get update --snapshot=${APT_UPDATE_SNAPSHOT}
EOF

################################################################################
# cross base stage
FROM --platform=$BUILDPLATFORM ubuntu:${UBUNTU_TAG} AS base-cross

ARG APT_UPDATE_SNAPSHOT
ARG DEBIAN_FRONTEND=noninteractive
RUN <<EOF
set -eu
apt-get update
apt-get install -y --no-install-recommends ca-certificates
apt-get update --snapshot=${APT_UPDATE_SNAPSHOT}
EOF

################################################################################
# cross build stage
FROM base-cross AS cross-build-stage

ARG APT_UPDATE_SNAPSHOT
ARG DEBIAN_FRONTEND=noninteractive
RUN <<EOF
set -eu
apt-get install -y --no-install-recommends --snapshot=${APT_UPDATE_SNAPSHOT} \
    build-essential \
    ca-certificates \
    curl \
    g++-riscv64-linux-gnu
EOF

ARG GOVERSION

WORKDIR /opt/build

RUN curl -fsSL https://go.dev/dl/go${GOVERSION}.linux-$(dpkg --print-architecture).tar.gz | \
  tar -C /usr/local -xzf -

ENV GOOS=linux
ENV GOARCH=riscv64
ENV CGO_ENABLED=1
ENV CC=riscv64-linux-gnu-gcc
ENV PATH=/usr/local/go/bin:${PATH}

COPY src .

RUN make

################################################################################
# runtime stage: produces final image that will be executed
FROM base-riscv64

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
COPY --from=cross-build-stage /opt/build/dapp .

ENV ROLLUP_HTTP_SERVER_URL="http://127.0.0.1:5004"

ENTRYPOINT ["rollup-init"]
CMD ["/opt/cartesi/dapp/dapp"]
