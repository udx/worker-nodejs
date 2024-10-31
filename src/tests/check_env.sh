#!/bin/bash
# Check Node.js and PM2 installations

set -e
echo "Checking Node.js and PM2 installations..."

NODE_VERSION_REQUIRED="20" # Adjust as needed
PM2_VERSION_REQUIRED="5"   # Adjust as needed

node_version=$(node -v | grep -oP '(\d+)' | head -1)
pm2_version=$(pm2 -v | grep -oP '(\d+)' | head -1)

if [[ "$node_version" == "$NODE_VERSION_REQUIRED" && "$pm2_version" == "$PM2_VERSION_REQUIRED" ]]; then
    echo "Node.js and PM2 are installed and accessible."
    echo "Node.js version: $(node -v)"
    echo "PM2 version: $(pm2 -v)"
else
    echo "Required versions: Node.js $NODE_VERSION_REQUIRED.x, PM2 $PM2_VERSION_REQUIRED.x"
    echo "Current versions: Node.js $(node -v), PM2 $(pm2 -v)"
    exit 1
fi
