const path = require("path");

// Define reusable paths and settings
const LOG_DIR = process.env.LOG_DIR || "/var/log/udx-worker-nodejs";
const SCRIPT = process.env.SCRIPT || path.join(__dirname, "../index.js");
const WATCH_MODE = process.env.WATCH_MODE === "true" || false;

module.exports = {
  apps: [
    {
      name: "udx-worker-nodejs",
      script: SCRIPT, // Entry script path
      instances: "max", // Max instances based on CPU cores
      exec_mode: "cluster", // Cluster mode for better performance
      env: {
        ...process.env,
        PM2_HOME: path.join(LOG_DIR, ".pm2"), // PM2 runtime home directory
      },
      watch: WATCH_MODE, // Enable watch based on environment
      ignore_watch: ["node_modules", "logs", "tmp"], // Prevent reloads from specified directories
      error_file: path.join(LOG_DIR, "error.log"), // Error log path
      out_file: path.join(LOG_DIR, "out.log"), // Output log path
      pid_file: path.join(LOG_DIR, "pm2.pid"), // PID file path
      pm2_log_path: path.join(LOG_DIR, "pm2.log"), // Main PM2 log path
      shutdown_with_message: true, // Graceful shutdown
    },
  ],
};
