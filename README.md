# linkerd — Ultralight service mesh (mTLS, retries/timeouts, golden signals)

[Linkerd](https://linkerd.io/) service mesh for the Kubernetes platform: every
injected workload receives a **per-pod identity** used for automatic mutual
TLS, with declarative retry/timeout policies and golden-signal network
telemetry — no application changes. Control plane pinned to the `stable`
channel (`stable-2.16`), installed into the `linkerd` namespace.

| Component | Image | Local (development) | Production |
| --- | --- | --- | --- |
| Control plane (destination, identity, proxy-injector) | `ghcr.io/linkerd/controller` | 1 replica per component, `values/linkerd-values.yaml` | HA (3 replicas), overrides in `infra-kubernetes/envs/<env>` |
| Data plane sidecars | `ghcr.io/linkerd/proxy` | Opt-in via `linkerd.io/inject: enabled` annotation | Same annotation in every service chart |

Integrates with the sibling projects:

- **infra-prometheus** ([infra-prometheus](https://github.com/sca-templates/infra-prometheus)) — scrapes mesh golden signals from every sidecar (`:4191/metrics`).
- **infra-grafana** ([infra-grafana](https://github.com/sca-templates/infra-grafana)) — dashboards for latency, throughput and error rate per service pair.
- **infra-kubernetes** ([infra-kubernetes](https://github.com/sca-templates/infra-kubernetes)) — declares the mesh rollout and the injection annotation per chart; ArgoCD applies it.
- **infra-consul** ([infra-consul](https://github.com/sca-templates/infra-consul)) — inside the cluster, Kubernetes DNS + Linkerd replace Consul discovery and TCP health checks entirely.

## Quick Start (local)

```bash
# 1. Prerequisites: kubectl + linkerd CLI + reachable cluster
make prerequisites

# 2. Install the control plane from values + post-install check
make install

# 3. Verify
make check
```

Injecting a workload is a change in its own repo's chart (annotation
`linkerd.io/inject: enabled`), applied through `infra-kubernetes`.

## Commands

| Command | Description |
| --- | --- |
| `make prerequisites` | kubectl, linkerd CLI and cluster reachability |
| `make install` | `linkerd check --pre`, apply control plane from values, post-check |
| `make check` | Full `linkerd check` suite |
| `make status` | Control-plane pods and versions |
| `make validate` | Static + live validation (`scripts/validate.sh`) |

## How mTLS identity flows

1. The proxy-injector webhook adds a sidecar proxy plus an identity slot to
   every pod carrying the injection annotation.
2. Linkerd **identity** issues a workload certificate (SPIFFE id
   `trustdomain.namespace.serviceaccount`) signed by the issuer; it rotates
   every 24 hours.
3. Proxies on both ends of a connection perform a handshake and only accept
   traffic between verified identities — east-west traffic is encrypted by
   default.

Issuer certificates are generated in-cluster; moving them behind
Vault/cert-manager is declared in `infra-kubernetes` (see
[docs/architecture.md](docs/architecture.md)).

## Networking

- Cluster-scoped install in the `linkerd` namespace; nothing is exposed
  outside the cluster.
- Every injected pod listens on `:4191/metrics` (golden signals) and
  `:4190` admin endpoints — loopback within the pod, scraped in-cluster.
- North-south traffic never enters through Linkerd: the edge is
  [infra-kong](https://github.com/sca-templates/infra-kong); Linkerd owns
  east-west only.

## Usage examples

```bash
# Control-plane health (the authoritative check)
linkerd check

# Versions (CLI must not be more than one minor ahead of the control plane)
linkerd version

# Control-plane pods
kubectl -n linkerd get pods

# Golden-signal telemetry lives per sidecar:
#   curl http://<pod>:4191/metrics | grep response_total
```

## Troubleshooting

| Symptom | Probable cause | Fix |
| --- | --- | --- |
| `linkerd check --pre` fails | Missing privileges / cluster unreachable | Check `kubectl cluster-info` and RBAC first |
| Pod stuck in `Pending` after injection | Sidecar init needs CAP_NET_ADMIN | Ensure CNI plugin or privileged init allowed |
| `linkerd version` mismatch warning | CLI newer than control plane | Bump the control plane (`LINKERD_VERSION`) or downgrade CLI |
| No metrics for a pair of services | Traffic never flowed since restart | Generate requests, then re-run `linkerd stat` |
| Webhook timeouts during deploys | proxy-injector overloaded | Scale controller replicas (HA values in prod) |

## Structure

```text
├── values/linkerd-values.yaml            # control-plane values (dev profile, SSOT)
├── scripts/
│   ├── install.sh                        # pre-check + apply + post-check
│   └── validate.sh                       # static + live PASS/FAIL suite
├── Makefile                              # orchestrator
├── .env.example                          # LINKERD_VERSION, namespace
├── docs/                                 # architecture, index
└── .claude/skills/ + .opencode/          # agent skills and commands
```
