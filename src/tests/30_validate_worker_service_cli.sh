#!/bin/sh

# Define the service name
SERVICE_NAME="nodejs_example"

# Start Worker PM service in the test environment
echo "Starting Worker PM service ${SERVICE_NAME}..."
worker service restart $SERVICE_NAME

# Wait briefly to ensure the service has time to start
sleep 2

# Check if the service started successfully
SERVICE_STATUS=$(worker service status $SERVICE_NAME | grep -o "RUNNING")
if [ "$SERVICE_STATUS" = "RUNNING" ]; then
    echo "Service ${SERVICE_NAME} started successfully with Worker PM and is running."
else
    echo "Service ${SERVICE_NAME} did not start as expected. Status: $SERVICE_STATUS"
    worker service stop $SERVICE_NAME
    exit 1
fi

# Stop and clean up the service
echo "Stopping and cleaning up the Worker PM service ${SERVICE_NAME}..."
worker service stop $SERVICE_NAME
echo "Service ${SERVICE_NAME} stopped."

echo "Validation completed successfully."
exit 0