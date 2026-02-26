import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  transpilePackages: ["@classmate/contracts", "@classmate/sdk"],
};

export default nextConfig;
