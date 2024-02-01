# syntax=docker.io/docker/dockerfile:1
FROM --platform=linux/riscv64 riscv64/ubuntu:22.04 as builder

ARG DEBIAN_FRONTEND=noninteractive
RUN <<EOF
set -e
apt-get update
apt-get install -y --no-install-recommends \
  build-essential=12.9ubuntu3 \
  lua5.4=5.4.4-1 \
  liblua5.4-dev=5.4.4-1 \
  luarocks=3.8.0+dfsg1-1
rm -rf /var/lib/apt/lists/*

luarocks install --lua-version=5.4 luasocket 3.1.0-1
luarocks install --lua-version=5.4 dkjson 2.6-1
EOF

FROM --platform=linux/riscv64 riscv64/ubuntu:22.04

ARG MACHINE_EMULATOR_TOOLS_VERSION=0.12.0
ADD https://github.com/cartesi/machine-emulator-tools/releases/download/v${MACHINE_EMULATOR_TOOLS_VERSION}/machine-emulator-tools-v${MACHINE_EMULATOR_TOOLS_VERSION}.deb /
RUN dpkg -i /machine-emulator-tools-v${MACHINE_EMULATOR_TOOLS_VERSION}.deb \
  && rm /machine-emulator-tools-v${MACHINE_EMULATOR_TOOLS_VERSION}.deb

LABEL io.sunodo.sdk_version=0.3.0
LABEL io.cartesi.rollups.ram_size=128Mi

ARG DEBIAN_FRONTEND=noninteractive
RUN <<EOF
set -e
apt-get update
apt-get install -y --no-install-recommends \
  busybox-static=1:1.30.1-7ubuntu3 \
  liblua5.4-dev=5.4.4-1 \
  lua5.4=5.4.4-1
rm -rf /var/lib/apt/lists/*
EOF

COPY --from=builder /usr/local/lib/lua /usr/local/lib/lua
COPY --from=builder /usr/local/share/lua /usr/local/share/lua

ENV PATH="/opt/cartesi/bin:/opt/cartesi/dapp:${PATH}"

WORKDIR /opt/cartesi/dapp
COPY . .

ENV ROLLUP_HTTP_SERVER_URL="http://127.0.0.1:5004"

ENTRYPOINT ["rollup-init"]
CMD ["lua", "dapp.lua"]
