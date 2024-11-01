# UDX Worker Node.js

A flexible Docker image designed to run various Node.js-based tasks, services, or APIs. Built on the udx-worker base image, it leverages Docker and PM2 for process management, making it ideal for both development and production environments.

## Overview

This image serves as a general-purpose environment for running Node.js applications. It’s well-suited for API servers, task runners, and service-based applications that need an optimized containerized setup.

### Based on udx-worker

As part of the udx-worker suite, this image inherits secure and efficient configurations, providing a robust foundation for Node.js applications.

## Development

### Prerequisites

- Ensure `Docker` is installed and running on your system.

### Quick Start

Place your Node.js scripts in the src/ directory to begin using this image. For example, you can add example.js:

// src/example.js
console.log("Hello from UDX Worker Node.js!");


### Running Built-In Tests

1. Clone this repository:

```
git clone https://github.com/udx/udx-worker-php.git
cd udx-worker-php
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

If you want to use the pre-built image directly from Docker Hub without cloning the repository:

1. Pull the Image:

```
docker pull usabilitydynamics/udx-worker-php:latest
```

2. Run the container with your application code:

```
docker run -d --name my-php-app \
  -v $(pwd)/my-php-app:/var/www/html \
  -p 80:80 \
  usabilitydynamics/udx-worker-php:latest
```

This serves your application at http://localhost.

3. Stop and remove the container when done:

```
docker rm -f my-php-app
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

3. Deploy Application Code. If your PHP application code is located in a different directory or repository, use the deploy target to mount it as a volume:

```
APP_PATH=/path/to/your-php-app make deploy
```

- Replace `/path/to/your-php-app` with the path to your PHP application directory.
- This command will mount your specified application directory into the container’s `/var/www/html` directory, allowing you to run your custom application directly.

## Configuration

You can configure build and runtime variables in `Makefile.variables`:

- PHP and NGINX versions. _(Only PHP8.3 supported for now)_
- Port mappings
- Source paths

Adjust these variables to suit your environment or specific deployment requirements.

## Makefile Commands Helper

Use make to view all available commands:

```
make help
```

These commands offer options for building, running, and testing your application seamlessly.