# syntax=docker.io/docker/dockerfile:1

# This enforces that the packages downloaded from the repositories are the same
# for the defined date, no matter when the image is built.
ARG UBUNTU_TAG=noble-20250404
ARG APT_UPDATE_SNAPSHOT=20250424T030400Z

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
  libtool
rm -rf /var/lib/apt/lists/*
EOF

WORKDIR /opt/cartesi/dapp
COPY 3rdparty ./3rdparty
COPY dapp.cpp ./
COPY Makefile ./
RUN make

################################################################################
# chiselled stage
FROM base AS chiselled

# Get chisel binary
ARG CHISEL_VERSION=1.1.0
RUN <<EOF
set -eu
curl -fsSL "https://github.com/canonical/chisel/releases/download/v${CHISEL_VERSION}/chisel_v${CHISEL_VERSION}_linux_riscv64.tar.gz" \
  -o /tmp/chisel.tar.gz
echo "ee651e2531d5af81a00629083a2bcd2cc05cae363f244a7d7e1f1f7eed43d9ecf97a5bfb03328716a16fc8f58a7d4dc4 /tmp/chisel.tar.gz" \
  | sha384sum -c
tar -xvf /tmp/chisel.tar.gz -C /usr/bin/
EOF

# Extract nodejs dependencies into the chiselled filesystem
WORKDIR /rootfs
RUN chisel cut \
  --release ubuntu-24.04 \
  --root /rootfs \
  --arch=riscv64 \
  # base rootfs dependencies
  base-files_base \
  base-passwd_data \
  # machine-emulator-tools dependencies
  busybox_bins \
  # dapp dependencies
  libstdc++6_libs

RUN <<EOF
  set -e
  ln -s /usr/bin/busybox bin/sh
  mkdir -p proc sys dev mnt
  echo "dapp:x:1000:1000::/home/dapp:/bin/sh" >> etc/passwd
  echo "dapp:x:1000:" >> etc/group
  mkdir home/dapp
  chown 1000:1000 home/dapp
  sed -i '/^root/s/bash/sh/g' etc/passwd
EOF

################################################################################
# machine-guest-tools stage
FROM base AS machine-guest-tools

ARG MACHINE_GUEST_TOOLS_VERSION=0.17.0
ARG DEBIAN_FRONTEND=noninteractive
WORKDIR /rootfs
RUN <<EOF
set -eu
cd /tmp
curl -fsSL https://github.com/cartesi/machine-guest-tools/releases/download/v${MACHINE_GUEST_TOOLS_VERSION}/machine-guest-tools_riscv64.tar.gz \
  -o /tmp/machine-guest-tools_riscv64.tar.gz
echo "2b6958eefdb59cb9c08ea530ac89dd41aa0ef06d3d4615e3bf81ef52fe01adb4b501e96b2153e7666994dd2a46ce17a815c9b2648c2dc0dc888edcc97fe8b553 /tmp/machine-guest-tools_riscv64.tar.gz" \
  | sha512sum -c
tar -xzf /tmp/machine-guest-tools_riscv64.tar.gz -C /rootfs
EOF

################################################################################
# runtime stage: produces final image that will be executed
FROM --platform=linux/riscv64 scratch

COPY --from=chiselled /rootfs /
COPY --from=machine-guest-tools /rootfs /

ENV PATH="/opt/cartesi/bin:/opt/cartesi/dapp:${PATH}"

WORKDIR /opt/cartesi/dapp
COPY --from=builder /opt/cartesi/dapp/dapp .

ENV ROLLUP_HTTP_SERVER_URL="http://127.0.0.1:5004"

ENTRYPOINT ["rollup-init"]
CMD ["/opt/cartesi/dapp/dapp"]
