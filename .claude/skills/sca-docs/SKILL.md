---
name: sca-docs
description: Enforce sca-docs conventions when writing or updating documentation (README.md, docs/). Use when the user asks to create, edit, or review documentation.
---

# sca-docs conventions

> Reference: <https://github.com/sca-templates/sca-docs>

## Rules (strict)

1. **English only** — all content, commit messages, PR descriptions.
2. **One fact, one place** — depth in this repo, topology in the vault, pointers in READMEs. Never duplicate.
3. **Naming** — folders `NN-area/`, files kebab-case English. ADRs: `adr-NNN-kebab-title.md`. Contracts: `grpc-<domain>.md`, `evt-<topic>.md`.
4. **Frontmatter** (vault notes only) — required fields: `title`, `type`, `status`, `repo`, `tags`. Closed taxonomy: `type/*`, `domain/*`, `stack/*`, `connectivity/*`, `status/*`.
5. **Links** — wikilinks `[[…]]` inside the vault; relative markdown links `../<repo>/path.md` toward repos.
6. **Catalogs** — update `INDEX.md` tables and regenerate `03-connections-map/connection-map.md` when contracts/services change.

## Definition of done

- [ ] Content in English
- [ ] Frontmatter valid (vault notes)
- [ ] INDEX.md catalogs updated
- [ ] No duplicated facts
- [ ] `npx markdownlint-cli2 "**/*.md"` passes

## Fetch conventions

Consult sca-docs via raw URLs:
`https://raw.githubusercontent.com/sca-templates/sca-docs/main/<path>`
