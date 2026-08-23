#!/usr/bin/env bash
# validate.sh — Verification of the Linkerd install (static + live).
#   Static: CLI/kubectl present, values file parses as YAML, .env.example keys.
#   Live (when a cluster is reachable): namespace exists, control plane ready,
#   linkerd check summary.
# Usage: make validate   (--static-only skips the live checks)
set -euo pipefail

LINKERD_VERSION="${LINKERD_VERSION:-stable-2.16}"
LINKERD_NAMESPACE="${LINKERD_NAMESPACE:-linkerd}"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATIC_ONLY="${1:-}"
PASS=0
FAIL=0

ok()   { (( PASS++ )) || true; echo "  OK  $1"; }
fail() { (( FAIL++ )) || true; echo "  FAIL $1"; }
section() { echo ""; echo "── $1 ──────────────────────────────────────"; }

section "Static checks"
if command -v kubectl >/dev/null; then
  ok "kubectl found"
else
  fail "kubectl not found"
fi
if command -v linkerd >/dev/null; then
  ok "linkerd CLI found ($(linkerd version --client --short 2>/dev/null))"
else
  fail "linkerd CLI not found"
fi
if [ -f "${PROJECT_DIR}/values/linkerd-values.yaml" ]; then
  ok "values/linkerd-values.yaml present"
else
  fail "values/linkerd-values.yaml missing"
fi
if npx --yes js-yaml "${PROJECT_DIR}/values/linkerd-values.yaml" > /dev/null 2>&1; then
  ok "values/linkerd-values.yaml parses as YAML"
else
  fail "values/linkerd-values.yaml invalid YAML"
fi

for key in ENVIRONMENT LINKERD_VERSION LINKERD_NAMESPACE; do
  if grep -q "^${key}=" "${PROJECT_DIR}/.env.example"; then
    ok ".env.example has ${key}"
  else
    fail ".env.example missing ${key}"
  fi
done

if [ "$STATIC_ONLY" = "--static-only" ]; then
  section "Result"
  echo "  Static-only mode: live checks skipped."
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  Result: ${PASS} OK, ${FAIL} FAIL"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  [ "$FAIL" -eq 0 ] && echo "  All static checks passed." || exit 1
  exit 0
fi

section "Cluster / control plane"
if ! kubectl cluster-info >/dev/null 2>&1; then
  fail "cluster unreachable (check KUBECONFIG)"
else
  ok "cluster reachable"
  NS_CODE="$(kubectl get namespace "$LINKERD_NAMESPACE" -o name 2>/dev/null || true)"
  if [ -n "$NS_CODE" ]; then
    ok "namespace ${LINKERD_NAMESPACE} exists"
  else
    fail "namespace ${LINKERD_NAMESPACE} missing (run: make install)"
  fi

  READY="$(kubectl -n "$LINKERD_NAMESPACE" get pods -o json 2>/dev/null \
    | python3 -c 'import sys,json; pods=json.load(sys.stdin)["items"]; print(sum(1 for p in pods if all(c["status"] == "True" and c.get("reason", "") != "PodInitializing" for c in p["status"].get("containerStatuses", []) if c["name"] != "linkerd-proxy")))') || echo 0)"
  TOTAL="$(kubectl -n "$LINKERD_NAMESPACE" get pods -o json 2>/dev/null \
    | python3 -c 'import sys,json; print(len(json.load(sys.stdin)["items"]))' 2>/dev/null || echo 0)"
  if [ "$TOTAL" -gt 0 ] && [ "$READY" -eq "$TOTAL" ]; then
    ok "control-plane pods ready (${READY}/${TOTAL})"
  else
    fail "control-plane pods ready (${READY}/${TOTAL})"
  fi

  section "linkerd check (summary)"
  if command -v linkerd >/dev/null && linkerd check --timeout 60s >/tmp/linkerd-check.$$ 2>&1; then
    ok "linkerd check passed ($(grep -c '√' /tmp/linkerd-check.$$ 2>/dev/null || echo '?') checks)"
  else
    fail "linkerd check failed — see full output with: linkerd check --timeout 60s"
  fi
  rm -f /tmp/linkerd-check.$$
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Result: ${PASS} OK, ${FAIL} FAIL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
[ "$FAIL" -eq 0 ] && echo "  All checks passed." || exit 1
