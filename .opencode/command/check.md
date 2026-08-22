---
description: Run the full Linkerd check suite and summarize failures.
agent: build
---

# Check

Run `make check` from the repo root and report the result. If checks fail,
isolate the failing section (`kubectl -n linkerd get pods`, `linkerd version`)
with the guidance in the `linkerd-lifecycle` skill, fix, then re-run.
