# UDX Worker Node.js Examples

This directory contains example services that demonstrate how to use the UDX Worker with Node.js applications.

## 🚀 Examples

### Simple Server
A basic HTTP server example that demonstrates:
- Setting up a Node.js HTTP server
- Worker service configuration
- Process management with supervisor
- Structured logging format

#### Configuration

1. Service configuration in `.config/worker/services.yaml`:
```yaml
kind: workerService
version: udx.io/worker-v1/service

services:
  - name: "simple-server"
    command: "node /usr/src/app/index.js"
    autostart: true
    autorestart: true
```

#### Running the Example

1. Using Docker directly:
```bash
docker run -d --name my-node-app \
  -v $(pwd)/simple-server:/usr/src/app \
  -v $(pwd)/simple-server/.config:/home/udx/.config \
  -p 8080:8080 \
  usabilitydynamics/udx-worker-nodejs:latest
```

2. Using docker-compose:
```yaml
version: '3'
services:
  app:
    image: usabilitydynamics/udx-worker-nodejs:latest
    volumes:
      - ./simple-server:/usr/src/app
      - ./simple-server/.config:/home/udx/.config
    ports:
      - "8080:8080"
```

3. Using worker-deployment:
```bash
npm install -g @udx/worker-deployment
cd src/examples
cp simple-server/deploy.yml deploy.yml
worker run
```

## 📁 Directory Structure
Each example follows this structure:
```
example-name/
├── .config/worker/          # Worker configuration directory
│   └── services.yaml       # Service definitions
└── index.js               # Application code
```

## 🔍 Volume Mounts
When running the examples, two key volume mounts are required:

1. Application Code:
   ```
   -v ./app:/usr/src/app
   ```
   Mounts your Node.js application code into the container

2. Worker Configuration:
   ```
   -v ./.config:/home/udx/.config
   ```
   Mounts the worker service configuration
