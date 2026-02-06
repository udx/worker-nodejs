# Delivery and Operations

## Scope
Summarize CI/CD, testing, release process, and runtime operations.

## Practices
- Use `make build` for Docker image builds and optional multi-platform builds via `buildx`.
- Use `make run` for standard container execution and `make run-it` for interactive debugging.
- Use `make run-all-tests` (or `make test`) to validate the runtime image using in-container tests.
- Include a readiness check for local runs that waits for the containerized app to return HTTP 200.
- Validate the runtime image with focused tests: Node.js version, task execution, and Worker service CLI behavior.
- Keep versioning consistent with CI configuration and branch-based increment rules.

## Evidence
- /Users/jonyfq/git/udx/worker-nodejs/Makefile
- /Users/jonyfq/git/udx/worker-nodejs/Makefile.help
- /Users/jonyfq/git/udx/worker-nodejs/Makefile.variables
- /Users/jonyfq/git/udx/worker-nodejs/src/tests/10_validate_environment.sh
- /Users/jonyfq/git/udx/worker-nodejs/src/tests/20_run_task_test.sh
- /Users/jonyfq/git/udx/worker-nodejs/src/tests/30_validate_worker_service_cli.sh
- /Users/jonyfq/git/udx/worker-nodejs/ci/git-version.yml
