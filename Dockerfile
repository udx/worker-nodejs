# Use the latest udx-worker as the base image
FROM usabilitydynamics/udx-worker:0.37.0

# Add metadata labels
LABEL version="0.27.0"

# Set build arguments for Node.js version and application port
ARG NODE_VERSION=22.21.1
ARG APP_PORT=8080

# Add Node.js to PATH
ENV PATH="/usr/local/node/bin:${PATH}"

# Set application-specific environment variables
ENV APP_HOME="/usr/src/app" \
    APP_PORT="${APP_PORT}"

# Use root user for Node.js installation
USER root

# Set shell with pipefail option for safer pipe operations
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Set working directory for Node.js installation
WORKDIR /tmp

# Install required packages for Node.js extraction
RUN set -ex && \
    apt-get update && \
    apt-get install -y --no-install-recommends xz-utils=5.8.1-1build2 && \
    rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN set -ex && \
    # Detect architecture
    ARCH=$(dpkg --print-architecture 2>/dev/null || echo "x64") && \
    if [ "$ARCH" = "amd64" ]; then ARCH="x64"; fi && \
    if [ "$ARCH" = "arm64" ]; then ARCH="arm64"; fi && \
    # Download Node.js binary and checksum
    curl -fsSLO "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${ARCH}.tar.xz" && \
    curl -fsSLO "https://nodejs.org/dist/v${NODE_VERSION}/SHASUMS256.txt" && \
    # Verify checksum
    grep " node-v${NODE_VERSION}-linux-${ARCH}.tar.xz\$" SHASUMS256.txt | sha256sum -c - && \
    # Extract and install
    mkdir -p /usr/local/node && \
    tar -xJf "node-v${NODE_VERSION}-linux-${ARCH}.tar.xz" --strip-components=1 -C /usr/local/node && \
    # Create symlinks
    ln -sf /usr/local/node/bin/node /usr/local/bin/node && \
    # Provide npm/npx launchers without /usr/bin/env (buildx/QEMU arm64-safe)
    printf '%s\n' '#!/bin/sh' \
    'exec node /usr/local/node/lib/node_modules/npm/bin/npm-cli.js "$@"' \
    > /usr/local/bin/npm && chmod +x /usr/local/bin/npm && \
    printf '%s\n' '#!/bin/sh' \
    'exec node /usr/local/node/lib/node_modules/npm/bin/npx-cli.js "$@"' \
    > /usr/local/bin/npx && chmod +x /usr/local/bin/npx && \
    # Verify installation
    node --version && \
    npm --version && \
    # Cleanup
    rm -rf /tmp/*

# Remove xz-utils as it's no longer needed
RUN apt-get purge -y --auto-remove xz-utils && \
    rm -rf /var/lib/apt/lists/*

# Copy application files
# Create application directory
RUN mkdir -p "${APP_HOME}" && \
    chown -R "${USER}:${USER}" "${APP_HOME}" && \
    chmod -R 755 "${APP_HOME}"

# Copy license and examples
COPY --chown=${USER}:${USER} LICENSE "${APP_HOME}/LICENSE"

# Expose the application port
EXPOSE ${APP_PORT}

# Switch to the non-root user and set working directory
USER "${USER}"
WORKDIR "${APP_HOME}"

# Use the parent image's entrypoint
ENTRYPOINT ["/usr/local/worker/bin/entrypoint.sh"]

# Use the default command from parent image
CMD ["tail", "-f", "/dev/null"]
