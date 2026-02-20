const { execSync } = require("node:child_process");
const path = require("node:path");

module.exports = async () => {
  const apiRoot = path.resolve(__dirname, "..");

  console.log("[jest-e2e] pushing test DB schema...");
  execSync("pnpm db:push:test", {
    cwd: apiRoot,
    stdio: "inherit",
    env: process.env,
  });
};
