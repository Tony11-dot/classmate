module.exports = {
  apps: [
    {
      name: "classmate-api",
      script: "dist/main.js",
      instances: "max",
      exec_mode: "cluster",
      env: {
        NODE_ENV: "production"
      }
    }
  ]
};
