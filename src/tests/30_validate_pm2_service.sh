#!/bin/sh

# Start PM2 service in the test environment (daemon mode)
echo "Starting PM2 service from ecosystem.config.js in test environment..."
pm2 start /usr/src/app/pm2/ecosystem.config.js --env test

# Wait briefly to ensure the service has time to start
sleep 2

# Check if the service started successfully
if pm2 list | grep -q "udx-worker-nodejs"; then
    SERVICE_STATUS=$(pm2 describe udx-worker-nodejs | grep "status" | awk '{print $4}')
    if [ "$SERVICE_STATUS" = "online" ]; then
        echo "Service started successfully with PM2 and is running."
    else
        echo "Service started but is not running as expected. Status: $SERVICE_STATUS"
        pm2 stop udx-worker-nodejs
        pm2 delete udx-worker-nodejs
        exit 1
    fi
else
    echo "Service did not start as expected."
    exit 1
fi

# Stop and delete the service to clean up
pm2 stop udx-worker-nodejs
pm2 delete udx-worker-nodejs
echo "Service stopped and cleaned up."
exit 0
