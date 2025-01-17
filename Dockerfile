# Use the udx-worker as the base image
FROM usabilitydynamics/udx-worker:0.8.0

# Add metadata labels
LABEL maintainer="UDX"
LABEL version="0.7.0"

# Set build arguments for Node.js version, application port, and log directory
ARG NODE_VERSION=22.x
ARG NODE_PACKAGE_VERSION=22.13.0-1nodesource1
ARG LOG_DIR=/var/log/udx-worker-nodejs
ARG APP_PORT=8080

# Set environment variables
ENV LOG_DIR=${LOG_DIR} APP_PORT=${APP_PORT}

# Set the working directory
WORKDIR /usr/src/app

# Use root user for package installations and file permissions setup
USER root

# Set the shell with pipefail option
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install Node.js with improved security
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION} | bash - && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        nodejs=${NODE_PACKAGE_VERSION} && \
    npm install -g npm@11.0.0 && \
    npm cache clean --force && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.npm/_cacache

# Copy application files
COPY src/index.js /usr/src/app/index.js
COPY src/configs/services.yml /etc/worker/services.yml
COPY src/tests/ /usr/src/app/tests/
COPY LICENSE /usr/src/app/LICENSE

# Ensure the log directory exists, then adjust permissions
RUN mkdir -p "${LOG_DIR}" \
    && chown -R "${USER}:${USER}" /usr/src/app /usr/src/app/tests "${LOG_DIR}" \
    && chmod -R 755 /usr/src/app "${LOG_DIR}"

# Expose the application port
EXPOSE ${APP_PORT}

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:${APP_PORT}/health || exit 1

# Switch to the non-root user defined in the base image as ${USER}
USER ${USER}

# Set the default command
CMD ["tail", "-f", "/dev/null"]