#!/bin/sh

# Required Node.js version
REQUIRED_NODE_VERSION="22"

# Check if Node.js is installed
if ! command -v node >/dev/null 2>&1; then
  echo "Error: Node.js is not installed or not in PATH."
  exit 2
fi

# Get current Node.js version
CURRENT_NODE_VERSION=$(node -v | awk -F. '{print $1}' | sed 's/v//')

# Check Node.js major version
echo "Checking Node.js installation..."
if [ "$CURRENT_NODE_VERSION" != "$REQUIRED_NODE_VERSION" ]; then
  echo "Node.js version does not match required version. Current: $CURRENT_NODE_VERSION, Required: $REQUIRED_NODE_VERSION.x"
  exit 1
fi

# Check if Worker PM is installed
if ! command -v worker >/dev/null 2>&1; then
  echo "Error: Worker PM is not installed or not in PATH."
  exit 3
fi

echo "Node.js version is correct and Worker PM is available."
exit 0