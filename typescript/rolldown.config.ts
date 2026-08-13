import { defineConfig } from "rolldown";

export default defineConfig({
  input: "src/index.ts",
  platform: "node",
  // bare imports are left out of the bundle: dependencies are installed in the
  // application image, and @cartesi/rollup is a native addon which can not be
  // bundled
  external: [/^[^./]/],
  output: {
    file: "dist/index.mjs",
    format: "esm",
  },
});
