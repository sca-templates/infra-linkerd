# Pull Request

## Summary

<!-- One or two lines: what this PR changes and why. -->

## Changes

<!-- List the notes/files touched. -->

## Checklist

- [ ] I have read [CONTRIBUTING.md](CONTRIBUTING.md).
- [ ] Content is in English.
- [ ] No secrets or kubeconfigs are committed (`.env`, `.secrets/` stay gitignored).
- [ ] `make prerequisites && make install` passes against a dev cluster (or static-only validation when no cluster is available).
- [ ] `bash -n scripts/*.sh` and `shellcheck scripts/*.sh` pass.
- [ ] `npx --yes markdownlint-cli2 README.md AGENTS.md CLAUDE.md .github/PULL_REQUEST_TEMPLATE.md .github/CONTRIBUTING.md docs/**/*.md .claude/skills/**/SKILL.md .opencode/command/*.md` passes.
- [ ] `README.md` is updated when versions, values or commands change.
