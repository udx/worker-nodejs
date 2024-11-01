const path = require("path");

const LOG_DIR = process.env.LOG_DIR || "/var/log/udx-worker-nodejs";
const SCRIPT = process.env.SCRIPT || path.join(__dirname, "../src/index.js"); // Adjusted path to src/index.js
const WATCH_MODE = process.env.WATCH_MODE === "true" || false;
const ENVIRONMENT = process.env.NODE_ENV || "production";

module.exports = {
  apps: [
    {
      name: "udx-worker-nodejs",
      script: SCRIPT,
      instances: ENVIRONMENT === "production" ? "max" : 1,
      exec_mode: ENVIRONMENT === "production" ? "cluster" : "fork",
      env: {
        PM2_HOME: path.join(LOG_DIR, ".pm2"),
      },
      env_development: {
        NODE_ENV: "development",
        LOG_LEVEL: "debug",
        watch: WATCH_MODE,
      },
      env_test: {
        NODE_ENV: "test",
        LOG_LEVEL: "info",
        instances: 1,
        exec_mode: "fork",
        watch: false,
      },
      env_production: {
        NODE_ENV: "production",
        LOG_LEVEL: "error",
        instances: "max",
        exec_mode: "cluster",
        watch: false,
      },
      watch: WATCH_MODE,
      ignore_watch: ["node_modules", "logs", "tmp"],
      error_file: path.join(LOG_DIR, "error.log"),
      out_file: path.join(LOG_DIR, "out.log"),
      pid_file: path.join(LOG_DIR, "pm2.pid"),
      pm2_log_path: path.join(LOG_DIR, "pm2.log"),
      shutdown_with_message: true,
    },
  ],
};
