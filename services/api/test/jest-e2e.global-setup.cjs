const crypto = require("crypto");
const dotenv = require("dotenv");
const path = require("path");

module.exports = async () => {
  // mimic package.json: DOTENV_CONFIG_PATH=.env.test node -r dotenv/config ...
  const envPath = process.env.DOTENV_CONFIG_PATH || ".env.test";
  dotenv.config({ path: path.resolve(process.cwd(), envPath), quiet: true });

  const base = process.env.DATABASE_URL;
  if (!base) {
    console.warn("[jest-e2e] DATABASE_URL missing; schema isolation skipped");
    return;
  }

  // only patch postgres urls
  if (!base.startsWith("postgresql://") && !base.startsWith("postgres://")) return;

  const schema = `e2e_${process.pid}_${Date.now()}_${crypto.randomBytes(4).toString("hex")}`;
  const u = new URL(base);
  u.searchParams.set("schema", schema);

  process.env.DATABASE_URL = u.toString();
  process.env.TEST_SCHEMA = schema;

  console.log("[jest-e2e] using schema:", schema);
};
