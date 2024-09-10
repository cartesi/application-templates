# syntax=docker.io/docker/dockerfile:1

# This enforces that the packages downloaded from the repositories are the same
# for the defined date, no matter when the image is built.
ARG UBUNTU_TAG=noble-20250127
ARG APT_UPDATE_SNAPSHOT=20250127T030400Z

################################################################################
# riscv64 base stage
FROM --platform=linux/riscv64 ubuntu:${UBUNTU_TAG} AS base-riscv64

ARG APT_UPDATE_SNAPSHOT
ARG DEBIAN_FRONTEND=noninteractive
RUN <<EOF
set -eu
apt-get update
apt-get install -y --no-install-recommends ca-certificates curl
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
apt-get install -y --no-install-recommends ca-certificates curl
apt-get update --snapshot=${APT_UPDATE_SNAPSHOT}
EOF

################################################################################
# cross build stage
FROM base-cross AS cross-build-stage

ARG DEBIAN_FRONTEND=noninteractive
RUN <<EOF
set -e
apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    g++-riscv64-linux-gnu
EOF

ARG GOVERSION=1.23.2

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

ARG DEBIAN_FRONTEND=noninteractive
RUN <<EOF
set -e
apt-get install -y --no-install-recommends \
  busybox-static
rm -rf /var/lib/apt/lists/* /var/log/* /var/cache/*
useradd --create-home --user-group dapp
EOF

ARG MACHINE_EMULATOR_TOOLS_VERSION=0.16.1
ADD https://github.com/cartesi/machine-emulator-tools/releases/download/v${MACHINE_EMULATOR_TOOLS_VERSION}/machine-emulator-tools-v${MACHINE_EMULATOR_TOOLS_VERSION}.deb /
RUN apt-get install -y --no-install-recommends /machine-emulator-tools-v${MACHINE_EMULATOR_TOOLS_VERSION}.deb \
  && rm /machine-emulator-tools-v${MACHINE_EMULATOR_TOOLS_VERSION}.deb

ENV PATH="/opt/cartesi/bin:${PATH}"

WORKDIR /opt/cartesi/dapp
COPY --from=cross-build-stage /opt/build/dapp .

ENV ROLLUP_HTTP_SERVER_URL="http://127.0.0.1:5004"

ENTRYPOINT ["rollup-init"]
CMD ["/opt/cartesi/dapp/dapp"]
