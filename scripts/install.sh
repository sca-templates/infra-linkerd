#!/usr/bin/env bash
# install.sh — Installs the Linkerd control plane from values/linkerd-values.yaml.
#   1. Verifies kubectl + linkerd CLI and cluster reachability
#   2. Runs linkerd check --pre
#   3. Applies `linkerd install --values <values>` and waits for a healthy mesh
# Usage: make install
set -euo pipefail

VALUES_FILE="${VALUES_FILE:-values/linkerd-values.yaml}"
LINKERD_VERSION="${LINKERD_VERSION:-stable-2.16}"
LINKERD_NAMESPACE="${LINKERD_NAMESPACE:-linkerd}"

command -v kubectl >/dev/null || { echo "ERROR: kubectl not found"; exit 1; }
command -v linkerd >/dev/null || { echo "ERROR: linkerd CLI not found (https://linkerd.io/2/getting-started/)"; exit 1; }
[ -f "$VALUES_FILE" ] || { echo "ERROR: $VALUES_FILE not found"; exit 1; }

echo "── Cluster reachable? ──"
kubectl cluster-info >/dev/null

echo "── CLI / control-plane version pin ──"
echo "Requested LINKERD_VERSION: ${LINKERD_VERSION} (CLI: $(linkerd version --client --short))"

echo "── linkerd check --pre ──"
linkerd check --pre --timeout 60s

echo "── Applying control plane (namespace: ${LINKERD_NAMESPACE}) ──"
linkerd install \
  --namespace "$LINKERD_NAMESPACE" \
  --values "$VALUES_FILE" \
  | kubectl apply -f -

echo "── Waiting for a healthy mesh (post-install check) ──"
linkerd check --timeout 300s

echo ""
echo "Linkerd installed. Next steps:"
echo "  - Inject workloads via 'linkerd.io/inject: enabled' in each service chart (infra-kubernetes)"
echo "  - make check   — full validation suite"
