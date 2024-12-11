# Use the udx-worker image as the base image
FROM usabilitydynamics/udx-worker:0.2.0

# Set build arguments for Node.js version, application port, and log directory
ARG NODE_VERSION=20.x
ARG NODE_PACKAGE_VERSION=20.17.0-1nodesource1
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

# Install Node.js and PM2
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION} | bash - \
    && apt-get install -y --no-install-recommends nodejs=${NODE_PACKAGE_VERSION} \
    && npm install -g pm2@5.4.2 \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy application files, PM2 configuration, and tests
COPY src/ /usr/src/app/
COPY pm2/ecosystem.config.js /usr/src/app/pm2/
COPY src/tests/ /usr/src/app/tests/
COPY LICENSE /usr/src/app/LICENSE

# Ensure the log directory exists, then adjust permissions
RUN mkdir -p "${LOG_DIR}" \
    && chown -R "${USER}:${USER}" /usr/src/app /usr/src/app/pm2 /usr/src/app/tests "${LOG_DIR}" \
    && chmod -R 755 /usr/src/app "${LOG_DIR}" \
    && chmod 644 /usr/src/app/pm2/ecosystem.config.js

# Expose the application port
EXPOSE ${APP_PORT}

# Add a health check for application readiness
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:${APP_PORT} || exit 1

# Switch to the non-root user defined in the base image as ${USER}
USER ${USER}

# Run PM2 with the ecosystem configuration in the foreground
CMD ["pm2", "start", "--no-daemon", "/usr/src/app/pm2/ecosystem.config.js"]
