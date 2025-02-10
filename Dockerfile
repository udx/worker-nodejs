# Use the udx-worker as the base image
FROM usabilitydynamics/udx-worker:0.12.0

# Add metadata labels
LABEL maintainer="UDX"
LABEL version="0.9.0"

# Set build arguments for Node.js version, application port, and log directory
ARG NODE_VERSION=22.13.1
ARG LOG_DIR=/var/log/udx-worker-nodejs
ARG APP_PORT=8080

# Set environment variables
ENV HOME="/usr/src/app"
ENV LOG_DIR=${LOG_DIR} APP_PORT=${APP_PORT}

# Use root user for package installations and file permissions setup
USER root

# Set the shell with pipefail option
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install Node.js
ARG TARGETARCH=amd64
RUN ARCH=$([ "$TARGETARCH" = "amd64" ] && echo "x64" || echo "arm64") && \
    curl -fsSL https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${ARCH}.tar.xz -o node.tar.xz && \
    tar -xJf node.tar.xz && \
    mv node-v${NODE_VERSION}-linux-${ARCH} /usr/local/node && \
    ln -s /usr/local/node/bin/node /usr/local/bin/node && \
    ln -s /usr/local/node/bin/npm /usr/local/bin/npm && \
    ln -s /usr/local/node/bin/npx /usr/local/bin/npx && \
    rm node.tar.xz && \
    rm -rf /tmp/* /var/tmp/*

# Copy application files
COPY src/index.js $HOME/index.js
COPY src/configs/services.yaml /usr/local/configs/worker/services.yaml
COPY src/tests/ $HOME/tests/
COPY LICENSE $HOME/LICENSE

# Ensure the log directory exists, then adjust permissions
RUN mkdir -p "${LOG_DIR}" \
    && chown -R "${USER}:${USER}" $HOME $HOME/tests "${LOG_DIR}" \
    && chmod -R 755 $HOME "${LOG_DIR}"

# Expose the application port
EXPOSE ${APP_PORT}

# Switch to the non-root user
USER ${USER}

# Set the working directory
WORKDIR $HOME

# Set the default command
CMD ["tail", "-f", "/dev/null"]