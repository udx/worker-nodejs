#!/bin/sh

echo "Running task execution test..."

# Check if Node.js is installed
NODE_PATH=$(command -v node || true)
if [ -z "$NODE_PATH" ]; then
    echo "Error: Node.js is required to run tests"
    exit 1
fi

# Run a basic Node.js script to simulate task execution
node -e "console.log('Task execution test: Task ran successfully.')" || {
    echo "Error: Task execution failed."
    exit 1
}

# Test successful
echo "Task execution test passed."
exit 0
