import * as esbuild from "esbuild";

await esbuild.build({
  entryPoints: ["src/index.js"],
  outfile: "dist/index.mjs",
  bundle: true,
  platform: "node",
  format: "esm",
  target: "node22",
  // dependencies are not bundled, they are installed in the application image,
  // as @cartesi/rollup is a native addon which can not be bundled
  packages: "external",
});
