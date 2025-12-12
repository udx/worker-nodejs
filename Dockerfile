# Use the latest udx-worker as the base image
FROM usabilitydynamics/udx-worker:0.35.0

# Add metadata labels
LABEL version="0.23.0"

# Set build arguments for Node.js version and application port
ARG NODE_VERSION=22.21.1
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

# Install required packages for Node.js extraction
RUN set -ex && \
    apt-get update && \
    apt-get install -y --no-install-recommends xz-utils=5.8.1-1build2 && \
    rm -rf /var/lib/apt/lists/*

# Install Node.js
ARG TARGETARCH

# Step 1: Detect and set architecture
RUN set -ex && \
    if [ -n "$TARGETARCH" ]; then \
        ARCH="$TARGETARCH"; \
    else \
        ARCH=$(dpkg --print-architecture 2>/dev/null || echo "amd64"); \
    fi && \
    case "$ARCH" in \
        amd64) ARCH="x64" ;; \
        arm64) ARCH="arm64" ;; \
        *) echo "Unsupported architecture: $ARCH" && exit 1 ;; \
    esac && \
    echo "Building for architecture: $ARCH" && \
    echo "$ARCH" > /tmp/node_arch.txt

# Step 2: Download Node.js binary
RUN set -ex && \
    ARCH=$(cat /tmp/node_arch.txt) && \
    echo "Downloading Node.js v${NODE_VERSION} for ${ARCH}..." && \
    curl -fsSLO "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${ARCH}.tar.xz" && \
    ls -lh "node-v${NODE_VERSION}-linux-${ARCH}.tar.xz"

# Step 3: Download checksum file
RUN set -ex && \
    echo "Downloading SHASUMS256.txt..." && \
    curl -fsSLO "https://nodejs.org/dist/v${NODE_VERSION}/SHASUMS256.txt" && \
    echo "Contents of SHASUMS256.txt:" && \
    head -n 5 SHASUMS256.txt

# Step 4: Verify checksum
RUN set -ex && \
    ARCH=$(cat /tmp/node_arch.txt) && \
    echo "Verifying checksum for node-v${NODE_VERSION}-linux-${ARCH}.tar.xz..." && \
    grep "node-v${NODE_VERSION}-linux-${ARCH}.tar.xz" SHASUMS256.txt | head -n1 > checksum.txt && \
    echo "Checksum line:" && \
    cat checksum.txt && \
    sha256sum -c checksum.txt

# Step 5: Extract and install Node.js
RUN set -ex && \
    ARCH=$(cat /tmp/node_arch.txt) && \
    echo "Extracting Node.js..." && \
    mkdir -p /usr/local/node && \
    tar -xJf "node-v${NODE_VERSION}-linux-${ARCH}.tar.xz" --strip-components=1 -C /usr/local/node && \
    ls -la /usr/local/node/bin/

# Step 6: Create symlinks
RUN set -ex && \
    echo "Creating symlinks..." && \
    ln -sf /usr/local/node/bin/node /usr/local/bin/node && \
    ln -sf /usr/local/node/bin/npm /usr/local/bin/npm && \
    ln -sf /usr/local/node/bin/npx /usr/local/bin/npx && \
    ls -la /usr/local/bin/node /usr/local/bin/npm /usr/local/bin/npx

# Step 7: Verify installation and cleanup
RUN set -ex && \
    echo "Verifying Node.js installation..." && \
    node --version && \
    npm --version && \
    echo "Cleaning up..." && \
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
