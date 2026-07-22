#!/bin/sh

# Required Node.js version
REQUIRED_NODE_VERSION="24"

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

# Verify that npm's bundled tar includes the security fix.
TAR_VERSION=$(node -p 'require("/usr/local/node/lib/node_modules/npm/node_modules/tar/package.json").version')
if ! node -e '
  const [major, minor, patch] = process.argv[1].split(".").map(Number);
  process.exit(major > 7 || (major === 7 && (minor > 5 || (minor === 5 && patch >= 19))) ? 0 : 1);
' "$TAR_VERSION"; then
  echo "Error: npm bundled tar must be at least 7.5.19. Current: $TAR_VERSION"
  exit 4
fi

echo "Node.js version is correct, npm bundled tar is patched, and Worker PM is available."
exit 0
