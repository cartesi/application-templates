# syntax=docker.io/docker/dockerfile:1

# This enforces that the packages downloaded from the repositories are the same
# for the defined date, no matter when the image is built.
ARG APT_UPDATE_SNAPSHOT=20250908T144407Z
ARG DEBIAN_TAG=trixie-20250908-slim@sha256:c2880112cc5c61e1200c26f106e4123627b49726375eb5846313da9cca117337
ARG RUST_VERSION=1.89

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
# cross build stage
FROM --platform=$BUILDPLATFORM rust:${RUST_VERSION}-slim-trixie AS cross-builder

COPY --link --from=apt-config / /

ARG DEBIAN_FRONTEND=noninteractive
RUN <<EOF
set -e
apt-get update
apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    g++-riscv64-linux-gnu
EOF

WORKDIR /opt/cartesi/dapp
COPY . .

RUN <<EOF
set -e
rustup target add riscv64gc-unknown-linux-gnu
cargo build --release
EOF

################################################################################
# runtime stage: produces final image that will be executed
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

# Strip non-determinism
rm -rf /var/lib/apt/lists/* /var/log/* /var/cache/*
apt-get dist-clean
EOF

ENV PATH="/opt/cartesi/bin:/opt/cartesi/dapp:${PATH}"

WORKDIR /opt/cartesi/dapp
COPY --from=cross-builder /opt/cartesi/dapp/target/riscv64gc-unknown-linux-gnu/release/dapp .

ENV ROLLUP_HTTP_SERVER_URL="http://127.0.0.1:5004"

ENTRYPOINT ["rollup-init"]
CMD ["dapp"]
