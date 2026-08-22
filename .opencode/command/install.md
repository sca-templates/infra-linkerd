---
description: Install the Linkerd control plane from values and wait for a healthy mesh.
agent: build
---

# Install

Run `make prerequisites && make install` from the repo root and report the
result. `install.sh` runs `linkerd check --pre`, applies
`values/linkerd-values.yaml`, then waits on `linkerd check`. On failure, use
the `linkerd-lifecycle` skill to isolate the stage before retrying.
