# Use the latest udx-worker as the base image
FROM usabilitydynamics/udx-worker:0.18.0

# Add metadata labels
LABEL version="0.12.0"

# Set build arguments for Node.js version and application port
ARG NODE_VERSION=22.14.0
ARG APP_PORT=8080

# Set application-specific environment variables
ENV APP_HOME="/usr/src/app" \
    APP_PORT="${APP_PORT}"

# Use root user for Node.js installation
USER root

# Set shell with pipefail option for safer pipe operations
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Set working directory for Node.js installation
WORKDIR /tmp

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
    ln -sf /usr/local/node/bin/npm /usr/local/bin/npm && \
    ln -sf /usr/local/node/bin/npx /usr/local/bin/npx && \
    # Verify installation
    node --version && \
    npm --version && \
    # Cleanup
    rm -rf /tmp/*

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
