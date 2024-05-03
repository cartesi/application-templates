# syntax=docker.io/docker/dockerfile:1

# build stage: includes resources necessary for installing dependencies

# Here the image's platform does not necessarily have to be riscv64.
# If any needed dependencies rely on native binaries, you must use 
# a riscv64 image such as cartesi/node:20-jammy for the build stage,
# to ensure that the appropriate binaries will be generated.
FROM node:20.8.0-bookworm as build-stage

WORKDIR /opt/cartesi/dapp
COPY . .
RUN yarn install && yarn build

# runtime stage: produces final image that will be executed

# Here the image's platform MUST be linux/riscv64.
# Give preference to small base images, which lead to better start-up
# performance when loading the Cartesi Machine.
FROM --platform=linux/riscv64 cartesi/node:20.8.0-jammy-slim

LABEL io.cartesi.rollups.sdk_version=0.6.0
LABEL io.cartesi.rollups.ram_size=128Mi

WORKDIR /opt/cartesi/dapp
COPY --from=build-stage /opt/cartesi/dapp/dist .

CMD ["node", "index.js"]
