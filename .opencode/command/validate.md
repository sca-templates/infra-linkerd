---
description: Run the static + live validation suite for this repo's Linkerd setup.
agent: build
---

# Validate

Run `make validate` from the repo root and report the result.
`validate.sh` checks CLI presence, values YAML validity, `.env.example`
keys, cluster reachability, control-plane readiness and a `linkerd check`
summary. If a check fails, isolate it with the guidance in the
`linkerd-lifecycle` skill and re-run.
