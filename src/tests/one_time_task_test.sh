#!/bin/bash
# Run a one-time Node.js task

set -e
echo "Running one-time task test..."

TASK_SCRIPT=${TASK_SCRIPT:-"console.log('One-time task execution successful')"}

output=$(node -e "$TASK_SCRIPT")
if [[ "$output" == "One-time task execution successful" ]]; then
    echo "One-time task ran successfully."
else
    echo "One-time task failed. Output: $output"
    exit 1
fi
