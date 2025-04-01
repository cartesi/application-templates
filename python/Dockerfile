# syntax=docker.io/docker/dockerfile:1

# This enforces that the packages downloaded from the repositories are the same
# for the defined date, no matter when the image is built.
ARG APT_UPDATE_SNAPSHOT=20250127T030400Z

################################################################################
# riscv64 base stage
FROM --platform=linux/riscv64 cartesi/python:3.13.2-slim-noble AS base

ARG APT_UPDATE_SNAPSHOT
ARG DEBIAN_FRONTEND=noninteractive
RUN <<EOF
set -eu
apt-get update
apt-get install -y --no-install-recommends ca-certificates curl
apt-get update --snapshot=${APT_UPDATE_SNAPSHOT}
EOF

################################################################################
# runtime stage: produces final image that will be executed

# Here the image's platform MUST be linux/riscv64.
# Give preference to small base images, which lead to better start-up
# performance when loading the Cartesi Machine.
FROM base

ARG DEBIAN_FRONTEND=noninteractive
RUN <<EOF
set -e
apt-get update
apt-get install -y --no-install-recommends \
  busybox-static
rm -rf /var/lib/apt/lists/* /var/log/* /var/cache/*
useradd --create-home --user-group dapp
EOF

ARG MACHINE_GUEST_TOOLS_VERSION=0.17.0-test3
ADD https://github.com/cartesi/machine-guest-tools/releases/download/v${MACHINE_GUEST_TOOLS_VERSION}/machine-guest-tools_riscv64.tar.gz  /tmp/machine-guest-tools_riscv64.tar.gz

RUN <<EOF
set -e
echo "944cb99a021fe94291bbd2682c22cae7be51bc5dc9120f720890ec420dd488f1f92a7fba26d3cc48037f212126de8042e41d3d6bda2c6df0b5d3cc43fe1eb27a /tmp/machine-guest-tools_riscv64.tar.gz" \
  | sha512sum -c
tar -C / -xzf /tmp/machine-guest-tools_riscv64.tar.gz
rm /tmp/machine-guest-tools_riscv64.tar.gz
EOF

ENV PATH="/opt/cartesi/bin:${PATH}"

WORKDIR /opt/cartesi/dapp
COPY ./requirements.txt .

RUN <<EOF
set -e
pip install -r requirements.txt --no-cache
find /usr/local/lib -type d -name __pycache__ -exec rm -r {} +
EOF

COPY ./dapp.py .

ENV ROLLUP_HTTP_SERVER_URL="http://127.0.0.1:5004"

ENTRYPOINT ["rollup-init"]
CMD ["python3", "dapp.py"]
