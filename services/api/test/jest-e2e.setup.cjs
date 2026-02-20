const { execSync } = require("child_process");

beforeAll(() => {
  execSync("pnpm -s -C services/api db:push:test", {
    stdio: "inherit",
    env: process.env,
  });
});
