<img src="assets/logo.svg" alt="UDX Worker Node.js">

# UDX Worker Node.js

[![Docker Pulls](https://img.shields.io/docker/pulls/usabilitydynamics/udx-worker-nodejs.svg)](https://hub.docker.com/r/usabilitydynamics/udx-worker-nodejs) [![License](https://img.shields.io/github/license/udx/worker-nodejs.svg)](LICENSE)

**Node.js runtime image built on UDX Worker with supervisor-based process management.**

[Quick Start](#-quick-start) • [Usage](#-usage) • [Development](#-development) • [Resources](#-resources)

## 🚀 Overview

UDX Worker Node.js provides:

- 🔧 **Node.js Runtime**: Ready-to-use environment for JavaScript apps
- 📦 **Process Management**: Supervisor-based service lifecycle
- 🛠️ **Service Configuration**: `services.yaml` for runtime services
- 🏗️ **Base Image**: Built on `udx-worker` for consistent ops

## 🏃 Quick Start

### Example: Simple Service

Use the included example in `src/examples/simple-server`:

```bash
docker pull usabilitydynamics/udx-worker-nodejs:latest
docker run -d --name my-node-app \
  -v $(pwd)/src/examples/simple-server:/usr/src/app \
  -v $(pwd)/src/examples/simple-server/.config:/home/udx/.config \
  -p 8080:8080 \
  usabilitydynamics/udx-worker-nodejs:latest
```

### Example: Custom Application

1. Create `.config/worker/services.yaml`:

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
```

2. Run with Docker Compose:

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

## ⚙️ Usage

### worker-deployment CLI

Use `@udx/worker-deployment` to standardize runs with `deploy.yml`:

```bash
npm install -g @udx/worker-deployment
worker config
worker run
```

This repo includes:
- `deploy.yml` (root template)
- `src/examples/simple-server/deploy.yml` (example)

### Configuration

Runtime and build variables live in `Makefile.variables`:

- Node.js version (default `22.x LTS`)
- Port mappings
- Source paths

## 🛠️ Development

```bash
git clone https://github.com/udx/worker-nodejs.git
cd worker-nodejs

make build
make test
```

To run a single test:

```bash
make run-test TEST_SCRIPT=10_validate_environment.sh
```

## 📚 Resources

- Base image docs: `udx/worker` — https://github.com/udx/worker
- Docker Hub: https://hub.docker.com/r/usabilitydynamics/udx-worker-nodejs
- Product page: https://udx.io/products/udx-worker-nodejs

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to your branch
5. Open a Pull Request

Please ensure your PR includes appropriate tests and documentation updates.

---
<div align="center">
Built by <a href="https://udx.io">UDX</a> © 2025
</div>
