#!/bin/sh

# Define the service name
SERVICE_NAME="simple-server"

# Start Worker PM service in the test environment
echo "Starting Worker PM service ${SERVICE_NAME}..."
worker service restart $SERVICE_NAME

# Wait for the service to start (up to 10 seconds)
for i in $(seq 1 10); do
    # Get service status and store in a temporary file (including stderr)
    worker service status $SERVICE_NAME > /tmp/service_status 2>&1
    
    # Display the status for debugging
    echo "Current service status:"
    cat /tmp/service_status
    
    # Check if service is running (look for both RUNNING and the check mark emoji)
    if grep -q -E "RUNNING" /tmp/service_status; then
        echo "Service ${SERVICE_NAME} started successfully with Worker PM and is running."
        
        # Stop and clean up the service
        echo "Stopping and cleaning up the Worker PM service ${SERVICE_NAME}..."
        worker service stop $SERVICE_NAME
        echo "Service ${SERVICE_NAME} stopped."
        
        # Clean up temp file
        rm -f /tmp/service_status
        
        echo "Validation completed successfully."
        exit 0
    fi
    
    if [ "$i" -eq 10 ]; then
        echo "Service failed to start after 10 attempts. Last status:"
        cat /tmp/service_status
        worker service stop $SERVICE_NAME
        rm -f /tmp/service_status
        exit 1
    fi
    
    echo "Waiting for service to start (attempt $i)..."
    sleep 1
done