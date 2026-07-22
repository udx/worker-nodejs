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

# Verify that npm's bundled tar includes the security fix. Resolve npm's global
# installation dynamically so the test follows the installed Node.js layout.
if ! TAR_VERSION=$(node -e '
  const { execFileSync } = require("node:child_process");
  const path = require("node:path");
  const npmRoot = execFileSync("npm", ["root", "--global"], { encoding: "utf8" }).trim();
  process.stdout.write(require(path.join(npmRoot, "npm/node_modules/tar/package.json")).version);
'); then
  echo "Error: unable to determine npm bundled tar version."
  exit 4
fi

if ! node -e '
  const match = /^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*)?(?:\+[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*)?$/.exec(process.argv[1]);
  if (!match) process.exit(1);
  const version = match.slice(1, 4).map(Number);
  const minimum = [7, 5, 19];
  const comparison = version.findIndex((part, index) => part !== minimum[index]);
  const hasPrerelease = process.argv[1].includes("-");
  process.exit(comparison === -1 ? (hasPrerelease ? 1 : 0) : (version[comparison] > minimum[comparison] ? 0 : 1));
' "$TAR_VERSION"; then
  echo "Error: npm bundled tar must be at least 7.5.19. Current: $TAR_VERSION"
  exit 4
fi

echo "Node.js version is correct, npm bundled tar is patched, and Worker PM is available."
exit 0
