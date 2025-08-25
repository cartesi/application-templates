# syntax=docker.io/docker/dockerfile:1

# This enforces that the packages downloaded from the repositories are the same
# for the defined date, no matter when the image is built.
ARG DEBIAN_TAG=trixie-20250811-slim@sha256:c85a2732e97694ea77237c61304b3bb410e0e961dd6ee945997a06c788c545bb
ARG APT_UPDATE_SNAPSHOT=20250811T210202Z

# Configure apt to use snapshot.debian.org
FROM scratch AS apt-config
ARG APT_UPDATE_SNAPSHOT
COPY <<EOF /etc/apt/sources.list.d/debian.sources
Types: deb
URIs: http://snapshot.debian.org/archive/debian/${APT_UPDATE_SNAPSHOT}
Suites: trixie trixie-updates
Components: main
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

Types: deb
URIs: http://snapshot.debian.org/archive/debian-security/${APT_UPDATE_SNAPSHOT}
Suites: trixie-security
Components: main
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF

# Configure apt to accept snapshots for expired suites (security, updates)
COPY <<EOF /etc/apt/apt.conf.d/10-nocheckvalid
Acquire::Check-Valid-Until false;
EOF

# Configure apt to Ignore TLS verify on first apt-get update --snapshot=
COPY <<EOF /etc/apt/apt.conf.d/99-insecure
Acquire::https::Verify-Peer false;
Acquire::https::Verify-Host false;
EOF

################################################################################
# riscv64 base stage
FROM --platform=linux/riscv64 debian:${DEBIAN_TAG} AS base

COPY --link --from=apt-config / /

ARG DEBIAN_FRONTEND=noninteractive
RUN <<EOF
set -e

apt-get update
apt-get install -y --no-install-recommends \
    ca-certificates
EOF

################################################################################
# riscv64 builder stage
FROM base AS builder
RUN rm /etc/apt/apt.conf.d/99-insecure

ARG DEBIAN_FRONTEND=noninteractive
RUN <<EOF
set -e
apt-get install -y --no-install-recommends \
  build-essential \
  liblua5.4-dev \
  lua5.4 \
  luarocks

luarocks install --lua-version=5.4 luasocket 3.1.0-1
luarocks install --lua-version=5.4 dkjson 2.6-1
EOF

################################################################################
# riscv64 final stage
FROM base
RUN rm /etc/apt/apt.conf.d/99-insecure

COPY <<EOF /tmp/machine-guest-tools_riscv64.deb.sha512sum
96625d97354c1cc905a8630f3d715f64b14bc5b89f3e30913d2eb02da3a01f20a7784d32c2ed340ca401dce4d1bc0e6bebfc3fbb3808725225c5793b16fa6ef4 /tmp/machine-guest-tools_riscv64.deb
EOF

ARG MACHINE_GUEST_TOOLS_VERSION=0.17.1
ARG DEBIAN_FRONTEND=noninteractive
RUN <<EOF
set -eu

apt-get install -y --no-install-recommends \
  busybox-static

cd /tmp
busybox wget https://github.com/cartesi/machine-guest-tools/releases/download/v${MACHINE_GUEST_TOOLS_VERSION}/machine-guest-tools_riscv64.deb
sha512sum -c /tmp/machine-guest-tools_riscv64.deb.sha512sum

apt-get install -y --no-install-recommends /tmp/machine-guest-tools_riscv64.deb
rm /tmp/machine-guest-tools_riscv64.deb

# Fix non-determinism issue when installing machine-guest-tools
cp -a /etc/shadow /etc/shadow-
EOF

RUN <<EOF
set -e
apt-get install -y --no-install-recommends \
  liblua5.4-dev \
  lua5.4

# Strip non-determinism
rm -rf /var/lib/apt/lists/* /var/log/* /var/cache/*
apt-get dist-clean
EOF

COPY --from=builder /usr/local/lib/lua /usr/local/lib/lua
COPY --from=builder /usr/local/share/lua /usr/local/share/lua

ENV PATH="/opt/cartesi/bin:${PATH}"

WORKDIR /opt/cartesi/dapp
COPY . .

ENV ROLLUP_HTTP_SERVER_URL="http://127.0.0.1:5004"

ENTRYPOINT ["rollup-init"]
CMD ["lua", "dapp.lua"]
