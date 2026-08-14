# JavaScript DApp Template

This is a template for JavaScript Cartesi DApps. It uses node to execute the backend application.
The application entrypoint is the `src/index.js` file. It is bundled with [rolldown](https://rolldown.rs), configured in `rolldown.config.js`, but any bundler can be used.

Requests are processed with the [`@cartesi/rollup`](https://cartesi.github.io/rollups-ts/rollup) package, which talks directly to the rollup device of the Cartesi Machine. The package is a pre-release, published under the `alpha` npm tag.

Dependencies are managed with [pnpm](https://pnpm.io), pinned by the `packageManager` field of `package.json` and installed through [corepack](https://nodejs.org/api/corepack.html):

```shell
corepack enable pnpm
pnpm install
```

## Running on the host

The same code runs on the development machine, where the package uses a mock driver that reads inputs from files and writes outputs next to them. Inputs are declared with the `CMT_INPUTS` environment variable, as a comma separated list of `reason:file` pairs, where `0` means an advance request and `1` an inspect request:

```shell
CMT_INPUTS="0:advance.bin" pnpm start
```

Advance inputs are ABI encoded, and can be generated with the [`@cartesi/codec`](https://cartesi.github.io/rollups-ts/codec) package. See [Testing on the Host](https://cartesi.github.io/rollups-ts/rollup/testing) for more details.
