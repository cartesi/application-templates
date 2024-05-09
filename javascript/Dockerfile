# syntax=docker.io/docker/dockerfile:1

# build stage: includes resources necessary for installing dependencies

# Here the image's platform does not necessarily have to be riscv64.
# If any needed dependencies rely on native binaries, you must use 
# a riscv64 image such as cartesi/node:20-jammy for the build stage,
# to ensure that the appropriate binaries will be generated.
FROM node:18-bookworm as build-stage

WORKDIR /opt/cartesi/dapp
COPY . .
RUN yarn install && yarn build

# chisel stage: produces final image that will be executed

# Here the image's platform MUST be linux/riscv64.
# Give preference to small base images, which lead to better start-up
# performance when loading the Cartesi Machine.
FROM --platform=linux/riscv64 riscv64/ubuntu:22.04 as chisel

WORKDIR /rootfs

ARG MACHINE_EMULATOR_TOOLS_VERSION=0.14.1
ADD https://github.com/cartesi/machine-emulator-tools/releases/download/v${MACHINE_EMULATOR_TOOLS_VERSION}/machine-emulator-tools-v${MACHINE_EMULATOR_TOOLS_VERSION}.deb /
RUN dpkg -x /machine-emulator-tools-v${MACHINE_EMULATOR_TOOLS_VERSION}.deb /rootfs

# Get chisel binary
ARG CHISEL_VERSION=0.9.1
ADD "https://github.com/canonical/chisel/releases/download/v${CHISEL_VERSION}/chisel_v${CHISEL_VERSION}_linux_riscv64.tar.gz" chisel.tar.gz
RUN tar -xvf chisel.tar.gz -C /usr/bin/

# Extract nodejs dependencies into the chiselled filesystem
ADD https://github.com/cartesi/chisel-releases.git#6c3f741b1bb22c49eba81a338195a40ad3239a78 /ubuntu-24.04-riscv64
RUN chisel cut \
  --release /ubuntu-24.04-riscv64 \
  --root /rootfs \
  --arch=riscv64 \
  # base rootfs dependencies
  base-files_base \
  base-passwd_data \
  # machine-emulator-tools dependencies
  busybox-static_bins \
  libgcc-s1_libs \
  # nodejs
  nodejs_bins

RUN <<EOF
  set -e
  ln -s /usr/bin/busybox bin/sh
  mkdir -p proc sys dev run/cruntime mnt
  echo "dapp:x:1000:1000::/home/dapp:/bin/sh" >> etc/passwd
  echo "dapp:x:1000:" >> etc/group
  mkdir home/dapp
  chown 1000:1000 home/dapp
  sed -i '/^root/s/bash/sh/g' etc/passwd
EOF

# runtime stage: final image
FROM --platform=linux/riscv64 scratch
LABEL io.cartesi.rollups.sdk_version=0.6.0
LABEL io.cartesi.rollups.ram_size=128Mi
ENV PATH="/opt/cartesi/bin:${PATH}"
WORKDIR /opt/cartesi/dapp
COPY --from=chisel /rootfs /
COPY --from=build-stage /opt/cartesi/dapp/dist /opt/cartesi/dapp
ENV ROLLUP_HTTP_SERVER_URL="http://127.0.0.1:5004"
ENTRYPOINT ["rollup-init"]
CMD ["node", "index.js"]
