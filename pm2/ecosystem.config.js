const path = require("path");

// Define reusable paths and settings
const LOG_DIR = process.env.LOG_DIR || "/var/log/udx-worker-nodejs";
const SCRIPT = process.env.SCRIPT || path.join(__dirname, "../src/index.js");
const WATCH_MODE = process.env.WATCH_MODE === "true" || false;

module.exports = {
  apps: [
    {
      name: "udx-worker-nodejs",
      script: SCRIPT, // Dynamic entry point
      instances: "max", // Max instances based on CPU cores
      exec_mode: "cluster", // Cluster mode for better performance
      env: process.env, // Inherit all environment variables
      watch: WATCH_MODE, // Enable watch based on environment
      ignore_watch: ["node_modules", "logs", "tmp"], // Prevent reloads from specified directories
      error_file: path.join(LOG_DIR, "error.log"), // Error logging
      out_file: path.join(LOG_DIR, "out.log"), // Output logging
      shutdown_with_message: true, // Graceful shutdown
    },
  ],
};
