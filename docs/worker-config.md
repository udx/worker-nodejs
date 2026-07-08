# Worker Config

`worker.yaml` is the checked-in Worker runtime config contract for this image.
Use it for image-level defaults and secret references that should travel with
the repo. Runtime platform values still win when the container is deployed.

## Shape

```yaml
kind: workerConfig
version: udx.io/worker-v1/config
config:
  env:
    APP_ENV: production
  secrets:
    DATABASE_URL:
      from: database-url
```

Keep `config.env` for non-sensitive defaults. Keep `config.secrets` for secret
references only, not literal secret values.

## Local Validation

Validate the manifest syntax before opening a PR:

```bash
yq e '.' worker.yaml
```

Refresh generated repo context after changing `worker.yaml` or this reference:

```bash
dev.kit repo
```

## Deployment Behavior

Deployment is external to the worker container. Use the host-native tool for
the target environment: Docker, Docker Compose, Kubernetes, Rabbit CI, or the
CI/CD platform's deployment step.

Mount `worker.yaml` and `services.yaml` through the target platform's normal
config and secret primitives. Keep image selection, volume mounts, ports, and
release behavior in the deployment platform, not in Worker runtime config.

Base Worker references:

- https://github.com/udx/worker/blob/latest/docs/config.md
- https://github.com/udx/worker/blob/latest/docs/secrets.md
- https://github.com/udx/worker/blob/latest/docs/deployment.md
