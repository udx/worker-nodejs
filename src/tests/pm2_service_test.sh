#!/bin/bash
# PM2 service test to check if it runs a sample process

set -e
echo "Starting PM2 service from ecosystem.config.js..."

# Stop any existing PM2 processes to prevent duplicates
pm2 delete all || true

# Start the PM2 service
pm2 start /usr/src/app/pm2/ecosystem.config.js --no-daemon

# Confirm that the service is running
if pm2 describe udx-worker-nodejs &> /dev/null; then
    echo "PM2 service started successfully."
else
    echo "PM2 service failed to start."
    pm2 logs
    exit 1
fi
