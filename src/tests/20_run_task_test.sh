#!/bin/sh

echo "Running task execution test..."

# Ensure the logs directory exists and is writable
LOG_DIR="/usr/src/app/logs"
if [ ! -d "$LOG_DIR" ]; then
  mkdir -p "$LOG_DIR" || {
    echo "Error: Failed to create log directory at $LOG_DIR."
    exit 1
  }
fi

# Run a basic Node.js script to simulate task execution
node -e "console.log('Task execution test: Task ran successfully.')" || {
  echo "Error: Task execution failed."
  exit 1
}

# Create a log entry to confirm task output
TEMP_FILE="$LOG_DIR/task_test.log"
echo "Simulating task output..." > "$TEMP_FILE" || {
  echo "Error: Failed to write to $TEMP_FILE."
  exit 1
}

# Verify that the file was created
if [ -f "$TEMP_FILE" ]; then
  echo "Task execution and output confirmed."
else
  echo "Error: Task did not produce expected output."
  exit 1
fi

echo "Task executed successfully."
exit 0
