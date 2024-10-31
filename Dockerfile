# Use the udx-worker image as the base image
FROM usabilitydynamics/udx-worker:0.1.0

# Set the Node.js version and port as build arguments
ARG NODE_VERSION=20.x
ARG NODE_PACKAGE_VERSION=20.17.0-1nodesource1
ARG APP_PORT=8080

# Set the working directory
WORKDIR /usr/src/app

# Copy the PM2 configuration and application files
COPY pm2/ /usr/src/app/pm2/
COPY src/ /usr/src/app/

# Install Node.js and PM2 as a process manager
USER root
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION} | bash - \
    && apt-get install -y nodejs=${NODE_PACKAGE_VERSION} \
    && npm install -g pm2@latest \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create and fix ownership of necessary directories for the non-root user
RUN mkdir -p /home/${USER}/.npm /var/log/udx-worker-nodejs/.pm2 /usr/src/app/logs \
    && chown -R ${USER}:${USER} /home/${USER}/.npm /var/log/udx-worker-nodejs /usr/src/app/logs

# Set environment variables for PM2
ENV PM2_HOME=/var/log/udx-worker-nodejs/.pm2
ENV PM2_LOG_DIR=/usr/src/app/logs
ENV PM2_PID_PATH=/usr/src/app/logs
ENV PM2_TMP_FOLDER=/usr/src/app/logs

# Switch back to non-root user for security
USER ${USER}

# Set environment variables (production mode)
ENV NODE_ENV=production

# Expose the application port
EXPOSE ${APP_PORT}

# Default to running PM2 with ecosystem
CMD ["pm2-runtime", "start", "/usr/src/app/pm2/ecosystem.config.js"]
