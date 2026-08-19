# Review Guidelines - worker-nodejs

Node.js runtime image, `FROM usabilitydynamics/udx-worker` (pinned tag), runs as UID 500. Direct parent of worker-engine AND docker-sftp: breakage here has two-repo blast radius before it ever reaches tenants.

## Critical Areas (extra scrutiny)

- Dockerfile: pinned `NODE_VERSION` / `NPM_VERSION` ARGs (keep pinned), `EXPOSE ${APP_PORT}`, `USER` directive, and the inherited entrypoint contract (`/usr/local/worker/bin/entrypoint.sh` from udx-worker). Do not override ENTRYPOINT.
- `worker.yaml`: worker config contract consumed by children.
- Any ownership/permission change: children assume UID 500 semantics from the base chain (authbind port binds, log dir ownership). Require downstream verification in worker-engine and docker-sftp for such changes.
- The Dockerfile `LABEL version` is known to drift from the actual GitVersion-published version; do not treat it as the source of truth, and flag PRs that bump only the label.

## Release Model

- Merge to `latest` cuts a Minor release IF the diff touches `Dockerfile`, `ci/**`, `src/**`, or `LICENSE`. GitVersion is the version source; there is no changelog, so the PR description must state downstream impact (do worker-engine/docker-sftp need FROM-pin bumps?).

## Conventions to Enforce

- shellcheck, hadolint, yamllint all green; `make test` (full local image build) passes.
- Keep the image minimal: this is a base image, so new packages need justification against child-image needs, not app convenience.
