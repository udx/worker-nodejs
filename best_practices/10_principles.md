# Principles and Architecture

## Scope
Summarize architecture, design, environment strategy, and repository structure.

## Practices
- Build on the `udx-worker` base image and keep this repo focused on Node.js runtime concerns.
- Treat the container as a Node.js runtime image: application code is mounted to `/usr/src/app`.
- Define long-running processes in `services.yaml` and mount it into `/home/udx/.config/worker` at runtime.
- Keep runtime behavior configurable through volume mounts and environment variables rather than rebuilding the image for each app.
- Use a stable Node.js major version in the image and validate it in tests.

## Evidence
- /Users/jonyfq/git/udx/worker-nodejs/README.md
- /Users/jonyfq/git/udx/worker-nodejs/Dockerfile
- /Users/jonyfq/git/udx/worker-nodejs/src/examples/README.md
- /Users/jonyfq/git/udx/worker-nodejs/src/tests/10_validate_environment.sh
