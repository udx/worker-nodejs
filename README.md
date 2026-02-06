<img src="assets/logo.svg" alt="UDX Worker Node.js">

[![Docker Pulls](https://img.shields.io/docker/pulls/usabilitydynamics/udx-worker-nodejs.svg)](https://hub.docker.com/r/usabilitydynamics/udx-worker-nodejs) [![License](https://img.shields.io/github/license/udx/worker-nodejs.svg)](LICENSE)

**Node.js runtime image built on UDX Worker.**

[Quick Start](#quick-start) • [Usage](#usage) • [Development](#development) • [Resources](#resources)

## Overview

UDX Worker Node.js is a Docker image that provides a ready-to-use Node.js runtime with the same operational model as `udx/worker` (https://github.com/udx/worker).

## Quick Start

Requirements: Docker and Node.js (for the CLI).

1. Install the deployment CLI (`@udx/worker-deployment`).

```bash
npm install -g @udx/worker-deployment
```

2. Generate a config and edit `deploy.yml` for your app.

```bash
worker config
```

3. Run the container.

```bash
worker run
```

Notes:

- `worker config` generates a `deploy.yml` in your current directory.
- Edit `deploy.yml` with your settings before running.
- Deploy config format and CLI reference: https://github.com/udx/worker/tree/main/docs/deploy/README.md
- `@udx/worker-deployment` on GitHub: https://github.com/udx/worker-deployment
- `@udx/worker-deployment` on npm: https://www.npmjs.com/package/@udx/worker-deployment

## Usage

### Deployment Configuration

- `deploy.yml` is the primary entrypoint for running this image.
- Schema and CLI behavior: https://github.com/udx/worker/tree/main/docs/deploy/README.md

### Runtime Services

- Define services in `.config/worker/services.yaml`.
- Service configuration: https://github.com/udx/worker/tree/main/docs/runtime/services.md

### Runtime Config and Secrets

- Define runtime config in `.config/worker/worker.yaml`.
- Runtime config and auth providers: https://github.com/udx/worker/tree/main/docs/runtime/config.md
- Authorization details: https://github.com/udx/worker/tree/main/docs/authorization.md

## Development

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

Build defaults for contributors live in `Makefile.variables` (Node.js version, ports, build args).

## Resources

- Base image docs: https://github.com/udx/worker
- Deployment CLI: https://github.com/udx/worker-deployment
- Docker Hub: https://hub.docker.com/r/usabilitydynamics/udx-worker-nodejs
- Product page: https://udx.io/products/udx-worker-nodejs

## Contributing

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
