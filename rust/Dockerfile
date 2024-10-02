# syntax=docker.io/docker/dockerfile:1

# This enforces that the packages downloaded from the repositories are the same
# for the defined date, no matter when the image is built.
ARG UBUNTU_TAG=noble-20240904.1
ARG APT_UPDATE_SNAPSHOT=20241001T030400Z

################################################################################
# riscv64 base stage
FROM --platform=linux/riscv64 ubuntu:${UBUNTU_TAG} AS base-riscv64

ARG APT_UPDATE_SNAPSHOT
ARG DEBIAN_FRONTEND=noninteractive
RUN <<EOF
set -eu
apt update
apt install -y --no-install-recommends ca-certificates curl
apt update --snapshot=${APT_UPDATE_SNAPSHOT}
EOF

################################################################################
# cross base stage
FROM --platform=$BUILDPLATFORM ubuntu:${UBUNTU_TAG} AS base-cross

ARG APT_UPDATE_SNAPSHOT
ARG DEBIAN_FRONTEND=noninteractive
RUN <<EOF
set -eu
apt update
apt install -y --no-install-recommends ca-certificates curl
apt update --snapshot=${APT_UPDATE_SNAPSHOT}
EOF

################################################################################
# cross build stage
FROM base-cross AS cross-build-stage

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    RUST_VERSION=1.81.0

ARG DEBIAN_FRONTEND=noninteractive
RUN <<EOF
set -e
apt install -y --no-install-recommends \
    build-essential \
    g++-riscv64-linux-gnu
EOF

RUN <<EOF
set -eux
dpkgArch="$(dpkg --print-architecture)"
case "${dpkgArch##*-}" in \
    amd64) rustArch='x86_64-unknown-linux-gnu'; rustupSha256='6aeece6993e902708983b209d04c0d1dbb14ebb405ddb87def578d41f920f56d' ;;
    armhf) rustArch='armv7-unknown-linux-gnueabihf'; rustupSha256='3c4114923305f1cd3b96ce3454e9e549ad4aa7c07c03aec73d1a785e98388bed' ;;
    arm64) rustArch='aarch64-unknown-linux-gnu'; rustupSha256='1cffbf51e63e634c746f741de50649bbbcbd9dbe1de363c9ecef64e278dba2b2' ;;
    i386) rustArch='i686-unknown-linux-gnu'; rustupSha256='0a6bed6e9f21192a51f83977716466895706059afb880500ff1d0e751ada5237' ;;
    *) echo >&2 "unsupported architecture: ${dpkgArch}"; exit 1 ;;
esac
url="https://static.rust-lang.org/rustup/archive/1.27.1/${rustArch}/rustup-init"
curl -fsSL -O "$url"
echo "${rustupSha256} *rustup-init" | sha256sum -c -
chmod +x rustup-init
./rustup-init -y --no-modify-path --profile minimal --default-toolchain $RUST_VERSION --default-host ${rustArch}
rm rustup-init
chmod -R a+w $RUSTUP_HOME $CARGO_HOME
rustup --version
cargo --version
rustc --version
EOF

RUN rustup target add riscv64gc-unknown-linux-gnu

WORKDIR /opt/cartesi/dapp
COPY . .
RUN cargo build --release

################################################################################
# runtime stage: produces final image that will be executed
FROM base-riscv64

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
    busybox-static
rm -rf /var/lib/apt/lists/* /var/log/* /var/cache/*
useradd --create-home --user-group dapp
EOF

ENV PATH="/opt/cartesi/bin:/opt/cartesi/dapp:${PATH}"

WORKDIR /opt/cartesi/dapp
COPY --from=cross-build-stage /opt/cartesi/dapp/target/riscv64gc-unknown-linux-gnu/release/dapp .

ENV ROLLUP_HTTP_SERVER_URL="http://127.0.0.1:5004"

ENTRYPOINT ["rollup-init"]
CMD ["dapp"]
