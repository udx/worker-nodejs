# UDX Worker Node.js

A versatile Docker image for running Node.js applications, providing a ready-to-use environment for deploying and managing your JavaScript projects with PM2.

## Overview

This image is designed as a general-purpose base for Node.js application development and deployment. It includes essential configurations to streamline your setup, making it easy to get started with APIs, task runners, and other Node.js services.

### Based on udx-worker

Built on `udx-worker`, this image benefits from secure, resource-efficient configurations and best practices, providing a reliable foundation for Node.js applications.

## Development

### Prerequisites

- Ensure `Docker` is installed and running on your system.

### Quick Start

This image serves as a base for your Node.js applications. The src/tests/ directory includes sample tests for verifying functionality, but it does not contain application code by default.

### Running Built-In Tests

1. Clone this repository:

```
git clone https://github.com/udx/udx-worker-nodejs.git
cd udx-worker-nodejs
```

2. Build the Docker image:

```
make build
```

3. Run Tests to verify functionality:

```
make run-all-tests
```

You can add additional tests in the `src/tests/` directory as needed.

## Deployment

### Deploying Using the Pre-Built Image

To use the pre-built image directly from Docker Hub without cloning the repository:

1. Pull the Image:

```
docker pull usabilitydynamics/udx-worker-nodejs:latest
```

2. Run the container with your application code:

```
docker run -d --name my-node-app \
  -v $(pwd)/my-node-app:/usr/src/app \
  -p 3000:3000 \
  usabilitydynamics/udx-worker-nodejs:latest
```

This serves your application at http://localhost:3000.

3. Stop and remove the container when done:

```
docker rm -f my-node-app
```

### Deploying Using a Locally Built Image (Makefile Approach)

If you’ve cloned this repository and built the image locally, you can use the provided Makefile targets:

1. Build the Image (if not already built):

```
make build
```

2. Run the Container:

```
make run
```

By default, this command runs the container with the code located in the `src/` directory of this repository.

3. Deploy Application Code: If your Node.js application code is located in a different directory or repository, use the deploy target to mount it as a volume:

```
APP_PATH=/path/to/your-node-app make deploy
```

- Replace `/path/to/your-node-app` with the path to your Node.js application directory.
- This command will mount your specified application directory into the container’s /usr/src/app directory, allowing you to run your custom application directly.

## Configuration

You can configure build and runtime variables in Makefile.variables:

- Node.js Version: Specify the version of Node.js required for your application.
- Port Mappings: Customize the ports to match your network setup.
- Source Paths: Define paths for application source files, logs, and other resources.

Adjust these variables to suit your environment or specific deployment requirements.

## Makefile Commands Helper

Use make to view all available commands:

```
make help
```

These commands offer options for building, running, and testing your application seamlessly.