# Contributing to infra-linkerd

> Ultralight service mesh for the platform — per-pod mTLS identity, declarative retry/timeout policies and golden-signal telemetry. Docs-as-code: all changes land through a PR with review.

## Ground rules

- **English only** — notes, commits, and PR descriptions are written in English.
- **No secrets in the repo** — `.env` (if used) and `.secrets/` (kubeconfigs) are gitignored. Never commit kubeconfigs, tokens or certificates.
- **Docs-as-code** — every change goes through a pull request and is reviewed.

## Repository layout

```text
values/linkerd-values.yaml   Control-plane values (dev profile, single source of truth)
scripts/                     install.sh | validate.sh
Makefile                     help | prerequisites | install | check | status | validate | uninstall | clean
.env.example                 Non-secret defaults (LINKERD_VERSION, namespace)
.github/                     CI, PR template, markdown link-check config
```

## Changing mesh configuration

1. Edit `values/linkerd-values.yaml` (dev SSOT). Per-environment overrides belong to `infra-kubernetes/envs/<env>` — keep both in sync.
2. Run `make prerequisites && make install` against a dev cluster.
3. Run `make validate`.
4. Update `README.md` / `docs/architecture.md` if topology or behavior changes; flag the sca-docs vault note in the PR if the change is material.

## Contribution flow

1. Branch off `main`: `git checkout -b feat/<topic>`.
2. Create or edit the files following the conventions above.
3. Run the checks (see Tooling).
4. Open a PR and fill the checklist from the template.

## Definition of done

- [ ] Content is in English.
- [ ] No secrets or kubeconfigs are committed (`.env`, `.secrets/` stay gitignored).
- [ ] `bash -n scripts/*.sh` and `shellcheck scripts/*.sh` pass.
- [ ] YAML files parse (`python3 -c "import yaml; yaml.safe_load(open('values/linkerd-values.yaml'))"`).
- [ ] `make validate` passes locally (cluster available) or static-only mode passes.
- [ ] `markdownlint` and link check pass (CI runs them too).
- [ ] `README.md` is updated when versions, values or commands change.

## Tooling

```sh
# Static + live validation
make validate

# Lint markdown
npx --yes markdownlint-cli2 README.md AGENTS.md CLAUDE.md .github/PULL_REQUEST_TEMPLATE.md .github/CONTRIBUTING.md docs/**/*.md .claude/skills/**/SKILL.md .opencode/command/*.md

# Check links in a single file (config lives in .github/)
npx --yes markdown-link-check -c .github/markdown-link-check.json <file>
```

## License

This repository is licensed under the MIT License (see [LICENSE](LICENSE)).
