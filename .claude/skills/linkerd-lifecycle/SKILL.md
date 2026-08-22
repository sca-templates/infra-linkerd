---
name: linkerd-lifecycle
description: Install, check and troubleshoot the Linkerd service mesh. Use when the user asks to make install/check/status/validate, inspect mesh mTLS or golden signals, or fix an unhealthy control plane or a pod that fails after injection.
---

# Linkerd lifecycle

- `make prerequisites` — kubectl + linkerd CLI + cluster reachability
- `make install` — pre-check, apply control plane from `values/linkerd-values.yaml`, post-check
- `make check` — full `linkerd check`
- `make status` — versions and control-plane pods
- `make validate` — static + live PASS/FAIL suite

## Health checks

- `linkerd version` — CLI vs control-plane versions must not drift more than one minor
- `kubectl -n linkerd get pods` — destination, identity, proxy-injector ready
- `linkerd check --timeout 120s` — authoritative suite

## Troubleshooting

- Pod stuck after injection: sidecar init needs CAP_NET_ADMIN — check CNI/privileged init.
- `linkerd check --pre` fails: cluster reachability/RBAC — verify `kubectl cluster-info`.
- Version mismatch warning: bump `LINKERD_VERSION` in `.env.example`/values and re-run `make install`; upgrades ride the ArgoCD release train in production.
- No telemetry for a service pair: no traffic since restart — generate requests, then `linkerd stat deploy/<name> --from <source>`.
