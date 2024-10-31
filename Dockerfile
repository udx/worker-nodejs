# Use the udx-worker image as the base image
FROM usabilitydynamics/udx-worker:0.1.0

# Set the Node.js and port as build arguments
ARG NODE_VERSION=20.x
ARG NODE_PACKAGE_VERSION=20.17.0-1nodesource1
ARG APP_PORT=8080

# Set the working directory
WORKDIR /usr/src/app

# Install Node.js and pm2 as a process manager
USER root
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION} | bash - \
    && apt-get install -y nodejs=${NODE_PACKAGE_VERSION} \
    && npm install -g pm2@latest \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Fix ownership of the npm cache folder for the non-root user
RUN mkdir -p /home/${USER}/.npm && chown -R ${USER}:${USER} /home/${USER}/.npm

# Switch back to non-root user for security
USER ${USER}

# Set environment variables (production mode)
ENV NODE_ENV=production

# Expose the application port
EXPOSE ${APP_PORT}

# Default to running PM2 with ecosystem, can override with CMD argument
CMD ["sh", "-c", "${CMD:-pm2-runtime start /usr/src/app/pm2/ecosystem.config.js}"]
