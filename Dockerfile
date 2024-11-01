# Use the udx-worker image as the base image
FROM usabilitydynamics/udx-worker:0.1.0

# Set the Node.js version and port as build arguments
ARG NODE_VERSION=20.x
ARG NODE_PACKAGE_VERSION=20.17.0-1nodesource1
ARG APP_PORT=8080

# Set USER root early to handle permissions
USER root

# Set the working directory
WORKDIR /usr/src/app

# Create necessary directories and set permissions for ${USER}
RUN mkdir -p /usr/src/app/pm2 /usr/src/app/logs /usr/src/app/.pm2 \
    && mkdir -p /var/log/udx-worker-nodejs/.pm2 \
    && chown -R ${USER}:${USER} /usr/src/app /usr/src/app/.pm2 /usr/src/app/pm2 /var/log/udx-worker-nodejs \
    && chmod -R 755 /usr/src/app /var/log/udx-worker-nodejs

# Copy application files and PM2 configuration
COPY src/ /usr/src/app/
COPY pm2/ecosystem.config.js /usr/src/app/pm2/

# Set permissions for PM2 configuration
RUN chown ${USER}:${USER} /usr/src/app/pm2/ecosystem.config.js \
    && chmod 644 /usr/src/app/pm2/ecosystem.config.js

# Install Node.js and PM2 using build arguments for version control
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION} | bash - \
    && apt-get install -y nodejs=${NODE_PACKAGE_VERSION} \
    && npm install -g pm2@latest \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Switch to the non-root user defined in the base image as ${USER}
USER ${USER}

# Expose the application port from the build argument
EXPOSE ${APP_PORT}

# Run PM2 with the ecosystem configuration in the foreground
CMD ["pm2", "start", "--no-daemon", "/usr/src/app/pm2/ecosystem.config.js"]
