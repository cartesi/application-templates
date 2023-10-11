# syntax=docker.io/docker/dockerfile:1.4
FROM --platform=linux/riscv64 riscv64/ubuntu:22.04 as builder

RUN <<EOF
apt-get update
apt-get install -y --no-install-recommends autoconf automake ca-certificates curl build-essential libtool wget 
rm -rf /var/lib/apt/lists/*
EOF

COPY --from=sunodo/sdk:0.2.0 /opt/riscv /opt/riscv
WORKDIR /opt/cartesi/dapp
COPY . .
RUN make

FROM --platform=linux/riscv64 riscv64/ubuntu:22.04

LABEL io.sunodo.sdk_version=0.2.0
LABEL io.cartesi.rollups.ram_size=128Mi

ARG MACHINE_EMULATOR_TOOLS_VERSION=0.12.0
RUN <<EOF
apt-get update
apt-get install -y --no-install-recommends busybox-static=1:1.30.1-7ubuntu3 ca-certificates=20230311ubuntu0.22.04.1 curl=7.81.0-1ubuntu1.14
curl -fsSL https://github.com/cartesi/machine-emulator-tools/releases/download/v${MACHINE_EMULATOR_TOOLS_VERSION}/machine-emulator-tools-v${MACHINE_EMULATOR_TOOLS_VERSION}.tar.gz \
  | tar -C / --overwrite -xvzf -
rm -rf /var/lib/apt/lists/*
EOF

ENV PATH="/opt/cartesi/bin:${PATH}"

WORKDIR /opt/cartesi/dapp
COPY --from=builder /opt/cartesi/dapp/dapp .

ENTRYPOINT ["/opt/cartesi/dapp/dapp"]
