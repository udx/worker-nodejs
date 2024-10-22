module.exports = {
    apps: [
      {
        name: "udx-worker-nodejs",
        script: "./src/index.js", // Entry point of your application
        instances: "max", // Launch as many instances as there are CPU cores
        exec_mode: "cluster", // Use cluster mode for better performance
        env: {
          NODE_ENV: "production",
        },
        env_development: {
          NODE_ENV: "development",
        },
        watch: true, // Enable watching of files to automatically restart on changes
        ignore_watch: ["node_modules", "logs"], // Directories to ignore for watching
      },
    ],
  };
  