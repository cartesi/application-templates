# syntax=docker.io/docker/dockerfile:1

# This enforces that the packages downloaded from the repositories are the same
# for the defined date, no matter when the image is built.
ARG UBUNTU_TAG=noble-20250404
ARG APT_UPDATE_SNAPSHOT=20250424T030400Z

################################################################################
# riscv64 base stage
FROM --platform=linux/riscv64 ubuntu:${UBUNTU_TAG} AS base

ARG APT_UPDATE_SNAPSHOT
ARG DEBIAN_FRONTEND=noninteractive
RUN <<EOF
set -eu
apt-get update
apt-get install -y --no-install-recommends ca-certificates curl
apt-get update --snapshot=${APT_UPDATE_SNAPSHOT}
EOF

################################################################################
# riscv64 builder stage
FROM base AS builder

ARG DEBIAN_FRONTEND=noninteractive
RUN <<EOF
set -e
apt-get install -y --no-install-recommends \
  build-essential \
  ruby-dev \
  ruby
rm -rf /var/apt/lists/*
gem install bundler --no-document
EOF

COPY Gemfile Gemfile.lock ./

RUN <<EOF
set -e
bundle config set --without 'development test'
bundle install --jobs=3 --retry=3
EOF

################################################################################
# runtime stage: produces final image that will be executed
FROM base
ARG MACHINE_GUEST_TOOLS_VERSION=0.17.0
ARG DEBIAN_FRONTEND=noninteractive
RUN <<EOF
set -e
apt-get install -y --no-install-recommends \
  busybox-static \
  ruby

cd /tmp
busybox wget https://github.com/cartesi/machine-guest-tools/releases/download/v${MACHINE_GUEST_TOOLS_VERSION}/machine-guest-tools_riscv64.deb
echo "973943b3a3e40164175da7d7b5b7857642d1277e1fd38be268da12daca5ff458735f93a7ac25b350b3de58b073a25b64c860d9eb92157bfc946b03dd1a345cc9 /tmp/machine-guest-tools_riscv64.deb" \
  | sha512sum -c
apt-get install -y --no-install-recommends \
  /tmp/machine-guest-tools_riscv64.deb
rm /tmp/machine-guest-tools_riscv64.deb

rm -rf /var/lib/apt/lists/* /var/log/* /var/cache/*
EOF

ENV PATH="/opt/cartesi/bin:${PATH}"

# Copy over gems from the dependencies stage
COPY --from=builder /var/lib/gems/ /var/lib/gems/

WORKDIR /usr/src/app
COPY . .

ENTRYPOINT ["rollup-init"]
CMD ["ruby", "main.rb"]
