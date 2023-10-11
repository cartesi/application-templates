# syntax=docker.io/docker/dockerfile:1.4
FROM --platform=linux/riscv64 riscv64/ubuntu:22.04 as base

RUN apt-get update

FROM base as builder

RUN <<EOF
apt-get install -y ruby="1:3.0~exp1" ruby-dev="1:3.0~exp1" build-essential=12.9ubuntu3
rm -rf /var/apt/lists/*
gem install bundler --no-document
EOF

COPY Gemfile Gemfile.lock ./

RUN <<EOF
bundle config set --without 'development test'
bundle install --jobs=3 --retry=3
EOF

FROM base

LABEL io.sunodo.sdk_version=0.2.0
LABEL io.cartesi.rollups.ram_size=128Mi

ARG MACHINE_EMULATOR_TOOLS_VERSION=0.12.0
RUN <<EOF
apt-get update
apt-get install -y --no-install-recommends busybox-static=1:1.30.1-7ubuntu3 ruby="1:3.0~exp1" ca-certificates=20230311ubuntu0.22.04.1 curl=7.81.0-1ubuntu1.14
curl -fsSL https://github.com/cartesi/machine-emulator-tools/releases/download/v${MACHINE_EMULATOR_TOOLS_VERSION}/machine-emulator-tools-v${MACHINE_EMULATOR_TOOLS_VERSION}.tar.gz \
  | tar -C / --overwrite -xvzf -
rm -rf /var/lib/apt/lists/*
EOF

ENV PATH="/opt/cartesi/bin:${PATH}"

# Copy over gems from the dependencies stage
COPY --from=builder /var/lib/gems/ /var/lib/gems/

WORKDIR /usr/src/app
COPY . .

ENTRYPOINT ["rollup-init"]
CMD ["ruby", "main.rb"]
