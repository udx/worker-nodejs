FROM usabilitydynamics/udx-worker:0.1.0-beta.538

# Switch to root user
USER root

# Copy the custom entrypoint script to the specified path and ensure it is executable
COPY ./bin/entrypoint.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

# Create work directory and set permissions
RUN mkdir -p /usr/src/app && chown -R $USER:$USER /usr/src/app

# Set work directory
WORKDIR /usr/src/app

# Copy the entire application, including the custom worker.yml configuration file
COPY . /usr/src/app
RUN chown -R $USER:$USER /usr/src/app

# Update, install necessary packages, and install Node.js in a single step
RUN apt-get update && apt-get install -y --no-install-recommends \
    git=1:2.43.0-1ubuntu7.1 \
    nano=7.2-2build1 \
    tcpdump=4.99.4-3ubuntu4 && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs=20.17.0-1nodesource1 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Clear npm cache or fix its permissions
RUN npm cache clean --force && chown -R $USER:$USER /home/$USER/.npm

# Install npm packages
RUN npm install

# Install @google-cloud/functions-framework
RUN npm install @google-cloud/functions-framework

# Install global npm packages (run as root)
RUN npm install -g

# Switch back to default user
USER $USER

EXPOSE 8080

# Use CMD to execute the entrypoint script
CMD ["/usr/local/bin/init.sh"]