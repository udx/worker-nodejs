# Use the udx-worker image as the base image
FROM usabilitydynamics/udx-worker:0.1.0

# Set the working directory
WORKDIR /usr/src/app

# Install Node.js 20 and pm2 as a process manager
USER root
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs=20.17.0-1nodesource1 \
    && npm install -g pm2@latest \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Fix ownership of the npm cache folder for the non-root user
RUN mkdir -p /home/${USER}/.npm && chown -R ${USER}:${USER} /home/${USER}/.npm

# Switch back to non-root user for security
USER ${USER}

# Set environment variables (production mode)
ENV NODE_ENV=production

# Expose the port your application will be running on
EXPOSE 8080

# Use pm2-runtime to run the app, specify the ecosystem file
CMD ["pm2-runtime", "src/configs/ecosystem.config.js"]
