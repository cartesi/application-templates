# syntax=docker.io/docker/dockerfile:1
ARG MACHINE_GUEST_TOOLS_VERSION=0.18.0
ARG MACHINE_GUEST_TOOLS_SHA256SUM=204d4260defd68e11b957ae1f1b511b6c2c74345c918748be06f592733b72dcd

# ################################################################################
# Java build stage (host arch)
FROM --platform=$BUILDPLATFORM eclipse-temurin:21-jdk-noble AS build

WORKDIR /app

COPY gradlew settings.gradle /app/
COPY gradle /app/gradle
COPY app/build.gradle /app/app/

RUN ./gradlew --no-daemon dependencies

COPY app/src /app/app/src

RUN ./gradlew --no-daemon shadowJar

# ################################################################################
# # Runtime stage (Cartesi-compatible: linux/riscv64)
FROM --platform=linux/riscv64 eclipse-temurin:21-jre-noble

ARG MACHINE_GUEST_TOOLS_VERSION
ARG MACHINE_GUEST_TOOLS_SHA256SUM
ADD --checksum=sha256:${MACHINE_GUEST_TOOLS_SHA256SUM} \
  https://github.com/cartesi/machine-guest-tools/releases/download/v${MACHINE_GUEST_TOOLS_VERSION}/machine-guest-tools_riscv64.deb \
  /tmp/machine-guest-tools_riscv64.deb

ARG DEBIAN_FRONTEND=noninteractive
RUN <<EOF
set -e
apt-get update
apt-get install -y --no-install-recommends \
  busybox-static \
  /tmp/machine-guest-tools_riscv64.deb

rm /tmp/machine-guest-tools_riscv64.deb
rm -rf /var/lib/apt/lists/* /var/log/* /var/cache/*
EOF

# Copy built JAR from Stage 1
WORKDIR /opt/cartesi/dapp
COPY --from=build /app/app/build/libs/app.jar ./app.jar

ENV PATH="/opt/cartesi/bin:${PATH}"
ENV ROLLUP_HTTP_SERVER_URL="http://127.0.0.1:5004"
ENTRYPOINT ["rollup-init"]
CMD ["java", "-jar", "app.jar"]
