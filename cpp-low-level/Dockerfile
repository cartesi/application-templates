# syntax=docker.io/docker/dockerfile:1.4
FROM --platform=linux/riscv64 riscv64/ubuntu:22.04 as builder

RUN <<EOF
apt-get update
apt-get install -y --no-install-recommends autoconf automake ca-certificates curl build-essential libtool wget 
rm -rf /var/lib/apt/lists/*
EOF

COPY --from=sunodo/sdk:0.1.0 /opt/riscv /opt/riscv
WORKDIR /opt/cartesi/dapp
COPY . .
RUN make

FROM --platform=linux/riscv64 riscv64/ubuntu:22.04

LABEL io.sunodo.sdk_version=0.1.0
LABEL io.cartesi.rollups.ram_size=128Mi

RUN <<EOF
apt-get update
apt-get install -y --no-install-recommends busybox-static=1:1.30.1-7ubuntu3
rm -rf /var/lib/apt/lists/*
EOF

COPY --from=sunodo/machine-emulator-tools:0.11.0-ubuntu22.04 / /
ENV PATH="/opt/cartesi/bin:${PATH}"

WORKDIR /opt/cartesi/dapp
COPY --from=builder /opt/cartesi/dapp/dapp .

ENTRYPOINT ["/opt/cartesi/dapp/dapp"]
