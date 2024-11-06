#!/bin/sh

# Required versions
REQUIRED_NODE_VERSION="20"
REQUIRED_PM2_VERSION="5"

# Check if Node.js is installed
if ! command -v node >/dev/null 2>&1; then
  echo "Error: Node.js is not installed or not in PATH."
  exit 2
fi

# Check if PM2 is installed and initialized
if ! command -v pm2 >/dev/null 2>&1; then
  echo "Error: PM2 is not installed or not in PATH."
  exit 3
fi

# Ensure PM2 is running
pm2 status >/dev/null 2>&1 || pm2 start

# Get current versions
CURRENT_NODE_VERSION=$(node -v | awk -F. '{print $1}' | sed 's/v//')
CURRENT_PM2_VERSION=$(pm2 -v | awk -F. '{print $1}')

# Check Node.js major version
echo "Checking Node.js and PM2 installations..."
if [ "$CURRENT_NODE_VERSION" != "$REQUIRED_NODE_VERSION" ]; then
  echo "Node.js version does not match required version. Current: $CURRENT_NODE_VERSION, Required: $REQUIRED_NODE_VERSION.x"
  exit 1
fi

# Check PM2 major version
if [ "$CURRENT_PM2_VERSION" != "$REQUIRED_PM2_VERSION" ]; then
  echo "PM2 version does not match required version. Current: $CURRENT_PM2_VERSION, Required: $REQUIRED_PM2_VERSION.x"
  exit 1
fi

echo "Node.js and PM2 versions are correct."
exit 0
