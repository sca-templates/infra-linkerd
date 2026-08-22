# Linkerd — Service Guide

Ultralight service mesh for the Kubernetes platform: per-pod mTLS identity,
declarative retry/timeout policies and golden-signal network telemetry without
application changes. This repo holds the declarative install values and
lifecycle tooling; the cluster rollout itself is applied by
[infra-kubernetes](https://github.com/sca-templates/infra-kubernetes) via ArgoCD.

## Ecosystem documentation (sca-docs)

The ecosystem docs live in the
[sca-docs](https://github.com/sca-templates/sca-docs) repository — the
single source of truth for ecosystem topology and conventions. Consult it
before writing or editing anything about topology, ports, networks, or
conventions. Principle: **one fact, one place** — depth lives in this repo,
topology/maps in the vault, pointers in READMEs.

- [04-infrastructure/INDEX.md](https://github.com/sca-templates/sca-docs/blob/main/04-infrastructure/INDEX.md) — infrastructure catalog
- [00-ecosystem/conventions.md](https://github.com/sca-templates/sca-docs/blob/main/00-ecosystem/conventions.md) — naming, links, catalogs
- [00-ecosystem/HOME.md](https://github.com/sca-templates/sca-docs/blob/main/00-ecosystem/HOME.md) — vault entry point
- [README.md](https://github.com/sca-templates/sca-docs/blob/main/README.md) — ecosystem vision + repository map
- [03-connections-map/connection-map.md](https://github.com/sca-templates/sca-docs/blob/main/03-connections-map/connection-map.md) — ecosystem graph
- [99-glossary/INDEX.md](https://github.com/sca-templates/sca-docs/blob/main/99-glossary/INDEX.md) — ubiquitous language
- [CONTRIBUTING.md](https://github.com/sca-templates/sca-docs/blob/main/CONTRIBUTING.md) — vault conventions and definition of done

Fetch them via the web, the GitHub API/MCP, or the raw URLs
(`https://raw.githubusercontent.com/sca-templates/sca-docs/main/<path>`).
Do not rely on a local checkout of `sca-docs`.

Keep the vault in sync: if a change materially alters this component (mesh
policies, injection defaults, telemetry), update the corresponding vault note
and open a PR in `sca-docs` — or flag it in this repo's PR.

## Project

Linkerd control plane (`stable` channel, version pinned in `.env.example`)
installed into the `linkerd` namespace from `values/linkerd-values.yaml`:

- **Automatic mTLS** — every injected workload receives a workload identity;
  service-to-service traffic is encrypted and mutually authenticated with no
  application changes.
- **Policy layer** — declarative retries and timeouts per route; authorization
  policies as the platform matures.
- **Golden-signal telemetry** — latency, throughput and error rate per pair of
  services, exposed on every sidecar at `:4191/metrics` and scraped by the
  platform Prometheus.
- Together with native Kubernetes DNS it replaces Consul discovery and TCP
  health checks entirely inside the cluster.

Full spec: the canonical note in the sca-docs vault
([infrastructure catalog](https://github.com/sca-templates/sca-docs/blob/main/04-infrastructure/INDEX.md)).

## Layout

- `values/linkerd-values.yaml` — the single source of truth for control-plane
  install values (dev profile); production overrides live in
  `infra-kubernetes/envs/<env>`.
- `scripts/install.sh` — prerequisite checks, `linkerd check --pre`, then
  `linkerd install --values ... | kubectl apply -f -`.
- `scripts/validate.sh` — CLI present, cluster reachable, control plane ready,
  `linkerd check` summary (PASS/FAIL counters).
- `.env.example` — non-secret vars (`LINKERD_VERSION`, namespace); `.env` is
  gitignored and optional.
- `.github/` — CI (`validate.yml`), PR template, CONTRIBUTING.
- `.mcp.json` + `.claude/` — Claude Code + codegraph MCP wiring.
- `.claude/skills/` — shared AI skills (`linkerd-lifecycle`, `sca-docs`);
  registered for opencode via `opencode.jsonc` (`skills.paths`).
- `opencode.jsonc` + `.opencode/` — opencode project config, MCP and
  `/install`, `/check`, `/status` commands.
- `docs/` — conceptual docs (architecture); operational content and
  troubleshooting live in `README.md`.
- `0.Project_info/` — user tooling (commit/merge/prompt flows); do not touch.

## Commands

- `make help` — all targets.
- `make prerequisites` — kubectl + linkerd CLI + cluster reachability.
- `make install` — pre-check, apply the control plane from values, post-check.
- `make check` — full `linkerd check`.
- `make status` — control-plane pods and versions.
- `make validate` — static + live validation suite (`scripts/validate.sh`).
- CI mirrors the static checks in `.github/workflows/validate.yml`.

## Conventions

- `values/linkerd-values.yaml` is the **single source of truth** for local/dev
  install flags. Per-environment overrides belong to `infra-kubernetes`
  (`envs/<env>`), never here.
- Workloads opt into the mesh via the `linkerd.io/inject: enabled` annotation
  declared in each service chart in `infra-kubernetes`; this repo does not
  inject anything by itself.
- Upgrades ride the platform release train: bump `LINKERD_VERSION`, update the
  values, let ArgoCD reconcile — never hand-edit a running mesh.
- Shell scripts: `set -euo pipefail` + a header comment only; no other comments.
- No Vault AppRole is wired here: Linkerd issues its own mTLS identities
  in-cluster; if issuer certificates move to Vault/cert-manager later, add the
  integration in `infra-kubernetes` and link it from `docs/architecture.md`.
- Content in English; changes land through a PR.
