# syntax=docker.io/docker/dockerfile:1

# This enforces that the packages downloaded from the repositories are the same
# for the defined date, no matter when the image is built.
ARG APT_UPDATE_SNAPSHOT=20250408T030400Z

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

ARG MACHINE_GUEST_TOOLS_VERSION=0.17.0-test6
ARG DEBIAN_FRONTEND=noninteractive
RUN <<EOF
set -e
apt-get install -y --no-install-recommends \
  busybox-static

cd /tmp
busybox wget https://github.com/cartesi/machine-guest-tools/releases/download/v${MACHINE_GUEST_TOOLS_VERSION}/machine-guest-tools_riscv64.deb
echo "850ddd259832497d122f05da54f91217852d57dd47c24a02efa66a44843b0f9c8c29cd81d3fa6d0f804d4a0b89466af00e619348dde94f23150cfd0f8bc930c8 /tmp/machine-guest-tools_riscv64.deb" \
  | sha512sum -c
apt-get install -y --no-install-recommends \
  /tmp/machine-guest-tools_riscv64.deb
rm /tmp/machine-guest-tools_riscv64.deb

rm -rf /var/lib/apt/lists/* /var/log/* /var/cache/*
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
