# syntax=docker.io/docker/dockerfile:1

# ################################################################################
# Java build stage (host arch)
FROM eclipse-temurin:21-jdk AS build

WORKDIR /app

COPY gradlew settings.gradle /app/
COPY gradle /app/gradle
COPY app/build.gradle /app/app/

RUN ./gradlew --no-daemon dependencies

COPY app/src /app/app/src

RUN ./gradlew --no-daemon shadowJar


# ################################################################################
# # Runtime stage (Cartesi-compatible: linux/riscv64)

FROM --platform=linux/riscv64 eclipse-temurin:21-jre

ARG MACHINE_GUEST_TOOLS_VERSION=0.17.0
RUN apt-get update && \
  apt-get install -y --no-install-recommends wget && \
  wget -O /tmp/tools.deb https://github.com/cartesi/machine-guest-tools/releases/download/v${MACHINE_GUEST_TOOLS_VERSION}/machine-guest-tools_riscv64.deb && \
  echo "973943b3a3e40164175da7d7b5b7857642d1277e1fd38be268da12daca5ff458735f93a7ac25b350b3de58b073a25b64c860d9eb92157bfc946b03dd1a345cc9 /tmp/tools.deb" | sha512sum -c && \
  apt-get install -y /tmp/tools.deb && \
  rm -f /tmp/tools.deb && \
  rm -rf /var/lib/apt/lists/*

# Copy built JAR from Stage 1
WORKDIR /opt/cartesi/dapp
COPY --from=build /app/app/build/libs/app.jar ./app.jar


ENV PATH="/opt/cartesi/bin:${PATH}"
ENV ROLLUP_HTTP_SERVER_URL="http://127.0.0.1:5004"
ENTRYPOINT ["rollup-init"]
CMD ["java", "-jar", "app.jar"]