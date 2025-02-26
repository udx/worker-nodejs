# UDX Worker Node.js

[![Docker Pulls](https://img.shields.io/docker/pulls/usabilitydynamics/udx-worker-nodejs.svg)](https://hub.docker.com/r/usabilitydynamics/udx-worker-nodejs) [![License](https://img.shields.io/github/license/udx/worker-nodejs.svg)](LICENSE)

**A versatile Docker image for running Node.js applications with built-in process management, providing a ready-to-use environment to deploy and manage your JavaScript projects.**

[Quick Start](#-quick-start) • [Development](#-development) • [Documentation](#-documentation) • [Contributing](#-contributing)

## 🚀 Overview

UDX Worker Node.js is a specialized Docker image built on UDX Worker that provides:

- 🔧 **Node.js Runtime**: Ready-to-use environment for JavaScript applications
- 📦 **Process Management**: Built-in supervisor-based service management
- 🛠️ **Service Configuration**: YAML-based service definition and control
- 🔄 **Zero Downtime**: Seamless application updates and restarts
- 🏗️ **Base Image**: Built on `udx-worker` for secure, efficient operations

## 👨‍💻 Development

### 📋 Prerequisites

- `Docker` installed and running on your system
- Node.js application code (optional)

## 🚀 Quick Start

### Example 1: Simple Service

1. Create a service configuration in `.config/worker/services.yaml`:

```yaml
kind: workerService
version: udx.io/worker-v1/service
services:
  - name: "node-app"
    command: "node index.js"
    autostart: true
    autorestart: true
    envs:
      - "PORT=3000"
```

2. Pull and run the image:

```bash
docker pull usabilitydynamics/udx-worker-nodejs:latest
docker run -d --name my-node-app -p 3000:3000 -v $(pwd)/.config:/home/udx/.config usabilitydynamics/udx-worker-nodejs:latest
```

### Example 2: Custom Application

1. Create your service configuration in `.config/worker/services.yaml`:

```yaml
kind: workerService
version: udx.io/worker-v1/service
services:
  - name: "api-server"
    command: "node api/server.js"
    autostart: true
    autorestart: true
    envs:
      - "PORT=3000"
      - "NODE_ENV=production"
  - name: "worker-queue"
    command: "node worker.js"
    autostart: true
    envs:
      - "QUEUE_URL=redis://localhost:6379"
```

2. Create a `docker-compose.yml`:

```yaml
version: '3'
services:
  app:
    image: usabilitydynamics/udx-worker-nodejs:latest
    volumes:
      - ./:/usr/src/app
      - ./.config:/home/udx/.config
    ports:
      - "3000:3000"
```

### Development Setup

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

## ⚙️ Configuration

You can configure build and runtime variables in `Makefile.variables`:

- Node.js version. _(Node.js 20.x LTS supported by default)_
- Port mappings
- Source paths

Adjust these variables to suit your environment or specific deployment requirements.

## 🛠️ Makefile Commands Helper

Use make to view all available commands:

```
make help
```

These commands offer options for building, running, and testing your application seamlessly.

## 📚 Documentation

### 🔧 Based on udx-worker

Built on [`udx-worker`](https://github.com/udx/worker), this image benefits from secure, resource-efficient configurations and best practices, providing a reliable foundation for Node.js applications.

### Core Concepts

- **Process Management**: Uses supervisor-based worker process manager
- **Service Configuration**: Defined through `services.yaml`
- **Configuration**: Customizable through `Makefile.variables`

### Additional Resources

- Build variables can be configured in `Makefile.variables`
- View available commands with `make help`
- Test examples available in `src/tests/`

## 🛠️ Development

Contribute to the project:

1. Fork the repository
2. Create your feature branch
3. Submit a pull request

## 🤝 Contributing
We welcome contributions! Here's how you can help:

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to your branch
5. Open a Pull Request

Please ensure your PR:
- Follows our coding standards
- Includes appropriate tests
- Updates relevant documentation

## 🔗 Resources
- [Docker Hub](https://hub.docker.com/r/usabilitydynamics/udx-worker-nodejs)
- [UDX Worker Documentation](https://github.com/udx/worker)
- [Product Page](https://udx.io/products/udx-worker-nodejs)

## 🎯 Custom Development
Need specific features or customizations?
[Contact our team](https://udx.io/) for professional development services.

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---
<div align="center">
Built by <a href="https://udx.io">UDX</a> © 2025
</div>