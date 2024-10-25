# UDX Worker Node.js Repository

This repository contains a containerized Node.js application built on the `udx-worker` base image. It uses Docker and PM2 for process management, supporting development, build, and deployment workflows.

## Development

### Prerequisites

- Docker installed.
- Node.js scripts should be placed in the `src/scripts/` directory (these scripts are not part of this repository and should be added by the user).

### Example Scripts

Place your Node.js scripts in the `src/scripts/` directory. Below is an example script (`example.js`) to help you get started:

```javascript
// src/scripts/example.js
console.log("Hello from UDX Worker Node.js!");
```

This simple script will log a message to the console when run inside the container.

### Key Commands

- **Build the Docker Image**: `make build`
- **Run the Container**: `make run`
- **Run in Interactive Mode**: `make run-it`
- **Exec into the Container**: `make exec`
- **View Logs**: `make log`

## Deployment

1. **Build the Image**: `make build`
2. **Push to Registry**: Tag and push the image to your container registry.
3. **Deploy Your Own App**:
   - Place your Node.js scripts in the `src/scripts/` directory.
   - Build and push the image to your registry.
   - Deploy using `docker run`, specifying your custom command if needed, e.g.,
     ```sh
     docker run -d --name udx-worker-nodejs -p 8080:8080 your-registry/udx-worker-nodejs:latest node /usr/src/app/scripts/example.js
     ```

## Cleanup

- **Remove Container**: `make clean`
