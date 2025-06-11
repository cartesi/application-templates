# syntax=docker.io/docker/dockerfile:1

ARG APT_UPDATE_SNAPSHOT=20250424T030400Z

################################################################################
# riscv64 base stage
FROM --platform=linux/riscv64 cartesi/node:22.14.0-noble-slim AS base

ARG APT_UPDATE_SNAPSHOT
ARG DEBIAN_FRONTEND=noninteractive
RUN <<EOF
set -eu
apt-get update
apt-get install -y --no-install-recommends ca-certificates curl
apt-get update --snapshot=${APT_UPDATE_SNAPSHOT}
EOF

################################################################################
# Java build stage (native arch)
FROM eclipse-temurin:21-jdk AS build-stage

WORKDIR /app

COPY gradlew settings.gradle /app/
COPY gradle /app/gradle
COPY app/build.gradle /app/app/

RUN ./gradlew --no-daemon dependencies

COPY app/src /app/app/src

RUN ./gradlew --no-daemon shadowJar

################################################################################
# Runtime stage (Cartesi-compatible: linux/riscv64)
FROM base

ARG MACHINE_GUEST_TOOLS_VERSION=0.17.0
ARG DEBIAN_FRONTEND=noninteractive

RUN <<EOF
set -e
apt-get update
apt-get install -y --no-install-recommends busybox-static default-jre-headless

cd /tmp
busybox wget https://github.com/cartesi/machine-guest-tools/releases/download/v${MACHINE_GUEST_TOOLS_VERSION}/machine-guest-tools_riscv64.deb
echo "973943b3a3e40164175da7d7b5b7857642d1277e1fd38be268da12daca5ff458735f93a7ac25b350b3de58b073a25b64c860d9eb92157bfc946b03dd1a345cc9 /tmp/machine-guest-tools_riscv64.deb" \
  | sha512sum -c
apt-get install -y --no-install-recommends /tmp/machine-guest-tools_riscv64.deb
rm /tmp/machine-guest-tools_riscv64.deb

rm -rf /var/lib/apt/lists/* /var/log/* /var/cache/*
EOF

ENV PATH="/opt/cartesi/bin:${PATH}"
ENV ROLLUP_HTTP_SERVER_URL="http://127.0.0.1:5004"

WORKDIR /opt/cartesi/dapp

# Copy the built JAR and dependencies from the build stage
COPY --from=build-stage /app/app/build/libs/app.jar ./app.jar

ENTRYPOINT ["rollup-init"]
CMD ["java", "-jar", "app.jar"]