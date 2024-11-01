const path = require("path");

// Define reusable paths and settings
const LOG_DIR = process.env.LOG_DIR || "/var/log/udx-worker-nodejs";
const SCRIPT = process.env.SCRIPT || path.join(__dirname, "../index.js");
const WATCH_MODE = process.env.WATCH_MODE === "true" || false;
const ENVIRONMENT = process.env.NODE_ENV || "production";

module.exports = {
  apps: [
    {
      name: "udx-worker-nodejs",
      script: SCRIPT, // Entry script path
      instances: ENVIRONMENT === "production" ? "max" : 1, // Use max instances in prod, 1 in other environments
      exec_mode: ENVIRONMENT === "production" ? "cluster" : "fork", // Cluster in production, fork for simplicity in dev/test
      env: {
        ...process.env,
        PM2_HOME: path.join(LOG_DIR, ".pm2"),
      },
      env_development: {
        NODE_ENV: "development",
        LOG_LEVEL: "debug",
        watch: WATCH_MODE, // Watch mode for development
      },
      env_test: {
        NODE_ENV: "test",
        LOG_LEVEL: "info",
        instances: 1, // Single instance for testing
        exec_mode: "fork", // Fork mode for isolated test instance
        watch: false,
      },
      env_production: {
        NODE_ENV: "production",
        LOG_LEVEL: "error",
        instances: "max", // Use all available CPU cores
        exec_mode: "cluster", // Use cluster mode for load distribution
        watch: false,
      },
      watch: WATCH_MODE, // Enable watch mode if set
      ignore_watch: ["node_modules", "logs", "tmp"], // Prevent reloads on changes in these directories
      error_file: path.join(LOG_DIR, "error.log"), // Error log path
      out_file: path.join(LOG_DIR, "out.log"), // Output log path
      pid_file: path.join(LOG_DIR, "pm2.pid"), // PID file path
      pm2_log_path: path.join(LOG_DIR, "pm2.log"), // Main PM2 log path
      shutdown_with_message: true, // Graceful shutdown
    },
  ],
};
